--[[
  Name: Parser.lua
  Author: ByteXenon
  Date: 2024-10-20
--]]

--* Dependencies *--
local Helpers     = require("Helpers/Helpers")
local NodeFactory = require("Parser/NodeFactory")

--* Imports *--
local stringToTable = Helpers.stringToTable
local insertValues  = Helpers.insertValues

local insert = table.insert
local max    = math.max
local min    = math.min
local rep    = string.rep

local createUnaryOperatorNode = NodeFactory.createUnaryOperatorNode
local createOperatorNode      = NodeFactory.createOperatorNode
local createFunctionCallNode  = NodeFactory.createFunctionCallNode

--* Constants *--
local CONTEXT_CHAR_RANGE = 20 -- The amount of characters to show around the error

-- Error Messages --
local ERROR_NO_TOKENS                             = "No tokens given"
local ERROR_NO_TOKENS_TO_PARSE                    = "No tokens to parse"
local ERROR_EXPECTED_EOF                          = "Expected EOF, got '%s'"
local ERROR_UNEXPECTED_TOKEN                      = "Unexpected token: '%s' in <primary>, expected constant, variable or function call"
local ERROR_EXPECTED_EXPRESSION                   = "Expected expression, got EOF"
local ERROR_EXPECTED_CLOSING_PARENTHESIS          = "Expected ')', got EOF"
local ERROR_EXPECTED_COMMA_OR_CLOSING_PARENTHESIS = "Expected ',' or ')', got '%s'"
local ERROR_NO_CHARSTREAM                         = "<No charStream, error message: %s>"

local DEFAULT_OPERATOR_PRECEDENCE_LEVELS = {
  Unary  = { ["-"] = 4 },
  Binary = { ["^"] = 3,
    ["*"] = 2, ["/"] = 2, ["%"] = 2,
    ["+"] = 1, ["-"] = 1 },
  RightAssociativeBinaryOperators = { ["^"] = true }
}

--* ParserMethods *--
local ParserMethods = {}

--- Get the next token from the token stream. N is the amount of tokens to skip.
-- @param <Number?> n=1 The amount of tokens to skip in order to get the next token.
-- @return <Table> token The next token.
function ParserMethods:peek(n)
  return self.tokens[self.currentTokenIndex + (n or 1)]
end

--- Consumes the next token from the token stream. N is the amount of tokens to go ahead.
-- @param <Number?> n=1 The amount of tokens to go ahead.
-- @return <Table> currentToken The current token
function ParserMethods:consume(n)
  local newCurrentTokenIndex = self.currentTokenIndex + (n or 1)
  local newCurrentToken      = self.tokens[newCurrentTokenIndex]
  self.currentTokenIndex = newCurrentTokenIndex
  self.currentToken      = newCurrentToken
  return newCurrentToken
end

--- Checks if the given token is a binary operator.
-- @param <Table?> token=currentToken The token to check.
-- @return <Boolean> isBinaryOperator Whether the token is a binary operator.
function ParserMethods:isBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.Binary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.Binary[token.Value]
end

--- Checks if the given token is an unary operator.
-- @param <Table?> token=currentToken The token to check.
-- @return <Boolean> isUnaryOperator Whether the token is an unary operator.
function ParserMethods:isUnaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.Unary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.Unary[token.Value]
end

--- Checks if the given token is a right associative binary operator.
-- @param <Table?> token=currentToken The token to check.
-- @return <Boolean> isRightAssociativeBinaryOperator Whether the token is a right associative binary operator.
function ParserMethods:isRightAssociativeBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.RightAssociativeBinaryOperators then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.RightAssociativeBinaryOperators[token.Value]
end

--- Checks if the current token is a function call
-- @return <Boolean> isFunctionCall Whether the current token is a function call.
function ParserMethods:isFunctionCall()
  local nextToken = self:peek()
  if not nextToken then return end
  return self.currentToken.TYPE == "Variable" and nextToken.TYPE == "Parentheses" and nextToken.Value == "("
end

--- Gets the precedence of the given token.
-- @param <Table> token The token to get the precedence of.
-- @return <Number> precedence The precedence of the token.
function ParserMethods:getPrecedence(token)
  return token and self.operatorPrecedenceLevels.Binary[token.Value]
end

--- Generate error message pointing to the current token.
-- @param <String> message The error message.
-- @param <...> ... The arguments to format the message with.
function ParserMethods:generateError(message, ...)
  if not self.expression then
    -- In case we don't have the charStream, we can't generate a proper error message
    return ERROR_NO_CHARSTREAM:format(message)
  end

  local charStream = stringToTable(self.expression)
  local message    = message:format(...)
  local position   = (not self.currentToken and #charStream + 1) or self.currentToken.Position
  local strippedExpressionTable = {}
  for index = max(1, position - CONTEXT_CHAR_RANGE), min(position + CONTEXT_CHAR_RANGE, #charStream) do
    insert(strippedExpressionTable, charStream[index])
  end
  local strippedExpression = table.concat(strippedExpressionTable)
  -- Make a pointer under the current token
  local pointer = rep(" ", position - 1) .. "^"
  return "\n" .. strippedExpression .. "\n" .. pointer .. "\n" .. message
end

--- Parses the function call.
-- @return <Table> expression The AST of the function call.
function ParserMethods:parseFunctionCall()
  -- <function call> ::= <variable> "(" <expression> ["," <expression>]* ")"
  local functionName = self.currentToken.Value
  self:consume(2) -- Consume the variable (function name) and the opening parenthesis
  local arguments = {}
  while true do
    local argument = self:parseExpression()
    insert(arguments, argument)
    if not self.currentToken then
      -- A little bit of backtracking to give a better error message
      local lastToken = self:peek(-1)
      if lastToken.TYPE == "Comma" then
        error(self:generateError(ERROR_EXPECTED_EXPRESSION))
      end
      error(self:generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
    elseif self.currentToken.Value == ")" then
      break
    elseif self.currentToken.TYPE == "Comma" then
      self:consume() -- Consume the comma
    else -- Unexpected token
      -- Is it even possible to reach this?
      error(self:generateError(ERROR_EXPECTED_COMMA_OR_CLOSING_PARENTHESIS, self.currentToken.Value))
    end
  end
  self:consume() -- Consume the closing parenthesis
  return createFunctionCallNode(functionName, arguments)
end

--- Parses the binary operator.
-- @param <Number> minPrecedence The minimum precedence of the operator.
-- @return <Table> expression The AST of the binary operator.
function ParserMethods:parseBinaryOperator(minPrecedence)
  -- <binary> ::= <unary> <binary operator> <binary> | <unary>
  local expression = self:parseUnaryOperator()
  while self:isBinaryOperator(self.currentToken) do
    local precedence = self:getPrecedence(self.currentToken)
    if precedence <= minPrecedence and not self:isRightAssociativeBinaryOperator(self.currentToken) then
      -- The current operator has a lower precedence than the minimum precedence, so we stop parsing
      -- Right associative operators are an exception, because they can be chained.
      break
    end
    local operatorToken = self.currentToken
    if not self:consume() then -- Consume the operator
      error(self:generateError(ERROR_EXPECTED_EXPRESSION))
    end
    local right = self:parseBinaryOperator(precedence)
    expression = createOperatorNode(operatorToken.Value, expression, right)
  end
  return expression
end

--- Parses the unary operator.
-- @return <Table> expression The AST of the unary operator.
function ParserMethods:parseUnaryOperator()
  -- <unary> ::= <unary operator> <unary> | <primary>
  if not self:isUnaryOperator(self.currentToken) then
    -- <primary>
    return self:parsePrimaryExpression()
  end
  -- <unary operator> <unary>
  local operator = self.currentToken.Value
  if not self:consume() then -- Consume the operator
    error(self:generateError(ERROR_EXPECTED_EXPRESSION))
  end

  local expression = self:parseUnaryOperator()
  return createUnaryOperatorNode(operator, expression)
end

--- Parses the primary expression.
-- @return <Table> expression The AST of the primary expression.
function ParserMethods:parsePrimaryExpression()
  -- <primary> ::= <constant> | <variable> | <function call> | "(" <expression> ")"
  local token = self.currentToken
  if not token then return end

  local tokenValue = token.Value
  local tokenType  = token.TYPE
  if tokenType == "Parentheses" and tokenValue == "(" then
    self:consume() -- Consume the opening parenthesis
    local expression = self:parseExpression()
    if not self.currentToken or self.currentToken.Value ~= ")" then
      error(self:generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
    end
    self:consume() -- Consume the closing parenthesis
    return expression
  elseif tokenType == "Variable" then
    -- Check if it's a function call first
    if self:isFunctionCall() then
      return self:parseFunctionCall()
    end

    -- It's a variable
    self:consume()
    return token
  elseif tokenType == "Constant" then
    self:consume()
    return token
  end

  error(self:generateError(ERROR_UNEXPECTED_TOKEN, tokenValue))
end

--- Parses the expression.
-- @return <Table> expression The AST of the expression.
function ParserMethods:parseExpression()
  local expression = self:parseBinaryOperator(0)
  return expression
end

--// PUBLIC METHODS \\--

--- Resets the parser to its initial state so it can be reused.
-- @param <Table> tokens The tokens to reset to.
-- @param <Table?> operatorPrecedenceLevels=DEFAULT_OPERATOR_PRECEDENCE_LEVELS The operator precedence levels to reset to.
function ParserMethods:resetToInitialState(givenTokens, givenOperatorPrecedenceLevels, givenTokenIndex, givenExpression)
  assert(givenTokens, ERROR_NO_TOKENS)

  self.tokens = givenTokens
  self.currentTokenIndex = givenTokenIndex or 1
  self.currentToken = givenTokens[givenTokenIndex or 1]

  self.operatorPrecedenceLevels = givenOperatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
  self.expression               = givenExpression
end

--- Parses the given tokens, and returns the AST.
-- @return <Table> expression The AST of the tokens.
function ParserMethods:parse(noErrors)
  assert(self.tokens, ERROR_NO_TOKENS_TO_PARSE)

  local expression = self:parseExpression()
  if self.currentToken and not noErrors then
    error(self:generateError(ERROR_EXPECTED_EOF, self.currentToken.Value))
  end

  return expression
end

--* Parser *--
local Parser = {}

--- @class Creates a new Parser instance
-- @param <Table> tokens The tokens to parse
-- @param <Table?> operatorPrecedenceLevels=DEFAULT_OPERATOR_PRECEDENCE_LEVELS The operator precedence levels to use in the parser
-- @param <Number?> tokenIndex=1 The index of the current token
-- @param <String|Table ?> expression=nil The expression to show during an error (e.g unexpected operator, etc.)
-- @return <Table> ParserInstance The Parser instance.
function Parser.new(tokens, operatorPrecedenceLevels, tokenIndex, expression)
  local ParserInstance = {}
  if tokens then
    ParserInstance.currentTokenIndex = tokenIndex or 1
    ParserInstance.currentToken = tokens[tokenIndex or 1]
  end
  ParserInstance.operatorPrecedenceLevels = operatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
  ParserInstance.expression               = expression

  insertValues(ParserMethods, ParserInstance)

  return ParserInstance
end

return Parser