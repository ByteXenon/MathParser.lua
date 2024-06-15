--[[
  Name: Parser.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-06-15
--]]

--* Dependencies *--
local Helpers = require("Helpers/Helpers")
local NodeFactory = require("Parser/NodeFactory")

--* Imports *--
local stringToTable = Helpers.stringToTable
local inheritModule = Helpers.inheritModule

local insert = table.insert
local concat = table.concat
local max = math.max
local min = math.min
local rep = string.rep

local createUnaryOperatorNode = NodeFactory.createUnaryOperatorNode
local createOperatorNode = NodeFactory.createOperatorNode
local createFunctionCallNode = NodeFactory.createFunctionCallNode

--* Constants *--

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
  Unary  = {   ["-"] = 4 },
  Binary = {   ["^"] = 3,
    ["*"] = 2, ["/"] = 2, ["%"] = 2,
    ["+"] = 1, ["-"] = 1 },
  RightAssociativeBinaryOperators = { ["^"] = true }
}

--* ParserMethods *--
local ParserMethods = {}

--// PRIVATE METHODS \\--

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
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isBinaryOperator Whether the token is a binary operator.
function ParserMethods:isBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.Binary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.Binary[token.Value]
end

--- Checks if the given token is an unary operator.
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isUnaryOperator Whether the token is an unary operator.
function ParserMethods:isUnaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.Unary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.Unary[token.Value]
end

--- Checks if the given token is a right associative binary operator.
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isRightAssociativeBinaryOperator Whether the token is a right associative binary operator.
function ParserMethods:isRightAssociativeBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedenceLevels.RightAssociativeBinaryOperators then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedenceLevels.RightAssociativeBinaryOperators[token.Value]
end

--- Checks if the current token is a function call
-- @return <Boolean> isFunctionCall Whether the current token is a function call.
function ParserMethods:isFunctionCall()
  local currentToken = self.currentToken
  local nextToken = self:peek()
  if not nextToken then return end
  return currentToken.TYPE == "Variable" and nextToken.TYPE == "Parentheses" and nextToken.Value == "("
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
  if not self.charStream then
    -- In case we don't have the charStream, we can't generate a proper error message
    return ERROR_NO_CHARSTREAM:format(message)
  end

  local message = message:format(...)
  local currentToken = self.currentToken
  local position = (not currentToken and #self.charStream + 1) or currentToken.Position
  local strippedExpressionTable = {}
  for index = max(1, position - 20), min(position + 20, #self.charStream) do
    insert(strippedExpressionTable, self.charStream[index])
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

    local currentToken = self.currentToken
    if not currentToken then
      -- A little bit of backtracking to give a better error message
      local lastToken = self:peek(-1)
      if lastToken.TYPE == "Comma" then
        error(self:generateError(ERROR_EXPECTED_EXPRESSION))
      end
      error(self:generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
    elseif currentToken.Value == ")" then
      break
    elseif currentToken.TYPE == "Comma" then
      self:consume() -- Consume the comma
    else -- Unexpected token
      -- Is it even possible to reach this?
      error(self:generateError(ERROR_EXPECTED_COMMA_OR_CLOSING_PARENTHESIS, currentToken.Value))
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
  local currentToken = self.currentToken
  while self:isBinaryOperator(currentToken) do
    local precedence = self:getPrecedence(currentToken)
    if precedence <= minPrecedence and not self:isRightAssociativeBinaryOperator(currentToken) then
      -- The current operator has a lower precedence than the minimum precedence, so we stop parsing
      -- Right associative operators are an exception, because they can be chained.
      break
    end

    if not self:consume() then -- Consume the operator
      error(self:generateError(ERROR_EXPECTED_EXPRESSION))
    end
    local right = self:parseBinaryOperator(precedence)
    expression = createOperatorNode(currentToken.Value, expression, right)
    currentToken = self.currentToken
  end
  return expression
end

--- Parses the unary operator.
-- @return <Table> expression The AST of the unary operator.
function ParserMethods:parseUnaryOperator()
  -- <unary> ::= <unary operator> <unary> | <primary>
  local currentToken = self.currentToken
  if not self:isUnaryOperator(currentToken) then
    -- <primary>
    return self:parsePrimaryExpression()
  end
  -- <unary operator> <unary>
  local operator = currentToken.Value
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

  local value = token.Value
  local TYPE = token.TYPE
  if TYPE == "Parentheses" and value == "(" then
    self:consume() -- Consume the opening parenthesis
    local expression = self:parseExpression()
    if not self.currentToken or self.currentToken.Value ~= ")" then
      error(self:generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
    end
    self:consume() -- Consume the closing parenthesis
    return expression
  elseif TYPE == "Variable" then
    -- Check if it's a function call first
    if self:isFunctionCall() then
      return self:parseFunctionCall()
    end

    -- It's a variable
    self:consume()
    return token
  elseif TYPE == "Constant" then
    self:consume()
    return token
  end

  error(self:generateError(ERROR_UNEXPECTED_TOKEN, value))
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
function ParserMethods:resetToInitialState(tokens, operatorPrecedenceLevels, tokenIndex, expression)
  assert(tokens, ERROR_NO_TOKENS)

  self.tokens = tokens
  self.currentToken = tokens[1]
  self.currentTokenIndex = 1

  self.operatorPrecedenceLevels = operatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
  self.charStream = (type(expression) == "string" and stringToTable(expression)) or expression
end

--- Parses the given tokens, and returns the AST.
-- @return <Table> expression The AST of the tokens.
function ParserMethods:parse(noErrors)
  assert(self.tokens, ERROR_NO_TOKENS_TO_PARSE)

  local expression = self:parseExpression()
  local remainingToken = self.currentToken
  if remainingToken and not noErrors then
    error(self:generateError(ERROR_EXPECTED_EOF, remainingToken.Value))
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
-- @return <Table> ParserInstance The Parser instance
function Parser:new(tokens, operatorPrecedenceLevels, tokenIndex, expression)
  local ParserInstance = {}
  if tokens then
    ParserInstance.tokens = tokens
    ParserInstance.currentTokenIndex = tokenIndex or 1
    ParserInstance.currentToken = tokens[ParserInstance.currentTokenIndex]
  end
  ParserInstance.operatorPrecedenceLevels = operatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
  ParserInstance.charStream = (type(expression) == "string" and stringToTable(expression)) or expression

  -- Main
  inheritModule("ParserInstance", ParserInstance, "ParserMethods", ParserMethods)

  return ParserInstance
end

return Parser