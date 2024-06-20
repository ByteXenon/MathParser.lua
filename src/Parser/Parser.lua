--[[
  Name: Parser.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-06-20
--]]

--* Dependencies *--
local Helpers     = require("Helpers/Helpers")
local NodeFactory = require("Parser/NodeFactory")

--* Imports *--
local stringToTable = Helpers.stringToTable
local inheritModule = Helpers.inheritModule

local insert = table.insert
local concat = table.concat
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
  Unary  = {   ["-"] = 4 },
  Binary = {   ["^"] = 3,
    ["*"] = 2, ["/"] = 2, ["%"] = 2,
    ["+"] = 1, ["-"] = 1 },
  RightAssociativeBinaryOperators = { ["^"] = true }
}

--* ParserMethods *--
local ParserMethods = {}

--* Parser *--
--- @class Creates a new Parser instance
-- @param <Table> tokens The tokens to parse
-- @param <Table?> operatorPrecedenceLevels=DEFAULT_OPERATOR_PRECEDENCE_LEVELS The operator precedence levels to use in the parser
-- @param <Number?> tokenIndex=1 The index of the current token
-- @param <String|Table ?> expression=nil The expression to show during an error (e.g unexpected operator, etc.)
-- @return <Table> ParserInstance The Parser instance.
local function Parser(tokens, operatorPrecedenceLevels, tokenIndex, expression)
  local currentTokenIndex, currentToken
  if tokens then
    currentTokenIndex = tokenIndex or 1
    currentToken = tokens[currentTokenIndex]
  end
  local operatorPrecedenceLevels = operatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
  local charStream = (type(expression) == "string" and stringToTable(expression)) or expression

  --- Get the next token from the token stream. N is the amount of tokens to skip.
  -- @param <Number?> n=1 The amount of tokens to skip in order to get the next token.
  -- @return <Table> token The next token.
  local function peek(n)
    return tokens[currentTokenIndex + (n or 1)]
  end

  --- Consumes the next token from the token stream. N is the amount of tokens to go ahead.
  -- @param <Number?> n=1 The amount of tokens to go ahead.
  -- @return <Table> currentToken The current token
  local function consume(n)
    local newCurrentTokenIndex = currentTokenIndex + (n or 1)
    local newCurrentToken      = tokens[newCurrentTokenIndex]
    currentTokenIndex = newCurrentTokenIndex
    currentToken      = newCurrentToken
    return newCurrentToken
  end

  --- Checks if the given token is a binary operator.
  -- @param <Table?> token=currentToken The token to check.
  -- @return <Boolean> isBinaryOperator Whether the token is a binary operator.
  local function isBinaryOperator(token)
    local token = token or currentToken
    if not operatorPrecedenceLevels.Binary then return end
    return token and token.TYPE == "Operator" and operatorPrecedenceLevels.Binary[token.Value]
  end

  --- Checks if the given token is an unary operator.
  -- @param <Table?> token=currentToken The token to check.
  -- @return <Boolean> isUnaryOperator Whether the token is an unary operator.
  local function isUnaryOperator(token)
    local token = token or currentToken
    if not operatorPrecedenceLevels.Unary then return end
    return token and token.TYPE == "Operator" and operatorPrecedenceLevels.Unary[token.Value]
  end

  --- Checks if the given token is a right associative binary operator.
  -- @param <Table?> token=currentToken The token to check.
  -- @return <Boolean> isRightAssociativeBinaryOperator Whether the token is a right associative binary operator.
  local function isRightAssociativeBinaryOperator(token)
    local token = token or currentToken
    if not operatorPrecedenceLevels.RightAssociativeBinaryOperators then return end
    return token and token.TYPE == "Operator" and operatorPrecedenceLevels.RightAssociativeBinaryOperators[token.Value]
  end

  --- Checks if the current token is a function call
  -- @return <Boolean> isFunctionCall Whether the current token is a function call.
  local function isFunctionCall()
    local nextToken = peek()
    if not nextToken then return end
    return currentToken.TYPE == "Variable" and nextToken.TYPE == "Parentheses" and nextToken.Value == "("
  end

  --- Gets the precedence of the given token.
  -- @param <Table> token The token to get the precedence of.
  -- @return <Number> precedence The precedence of the token.
  local function getPrecedence(token)
    return token and operatorPrecedenceLevels.Binary[token.Value]
  end

  --- Generate error message pointing to the current token.
  -- @param <String> message The error message.
  -- @param <...> ... The arguments to format the message with.
  local function generateError(message, ...)
    if not charStream then
      -- In case we don't have the charStream, we can't generate a proper error message
      return ERROR_NO_CHARSTREAM:format(message)
    end

    local message = message:format(...)
    local position = (not currentToken and #charStream + 1) or currentToken.Position
    local strippedExpressionTable = {}
    for index = max(1, position - CONTEXT_CHAR_RANGE), min(position + CONTEXT_CHAR_RANGE, #charStream) do
      insert(strippedExpressionTable, charStream[index])
    end
    local strippedExpression = table.concat(strippedExpressionTable)
    -- Make a pointer under the current token
    local pointer = rep(" ", position - 1) .. "^"
    return "\n" .. strippedExpression .. "\n" .. pointer .. "\n" .. message
  end

  local parseFunctionCall, parseBinaryOperator, parseUnaryOperator,
        parsePrimaryExpression, parseExpression

  --- Parses the function call.
  -- @return <Table> expression The AST of the function call.
  function parseFunctionCall()
    -- <function call> ::= <variable> "(" <expression> ["," <expression>]* ")"
    local functionName = currentToken.Value
    consume(2) -- Consume the variable (function name) and the opening parenthesis
    local arguments = {}
    while true do
      local argument = parseExpression()
      insert(arguments, argument)
      if not currentToken then
        -- A little bit of backtracking to give a better error message
        local lastToken = peek(-1)
        if lastToken.TYPE == "Comma" then
          error(generateError(ERROR_EXPECTED_EXPRESSION))
        end
        error(generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
      elseif currentToken.Value == ")" then
        break
      elseif currentToken.TYPE == "Comma" then
        consume() -- Consume the comma
      else -- Unexpected token
        -- Is it even possible to reach this?
        error(generateError(ERROR_EXPECTED_COMMA_OR_CLOSING_PARENTHESIS, currentToken.Value))
      end
    end
    consume() -- Consume the closing parenthesis
    return createFunctionCallNode(functionName, arguments)
  end

  --- Parses the binary operator.
  -- @param <Number> minPrecedence The minimum precedence of the operator.
  -- @return <Table> expression The AST of the binary operator.
  function parseBinaryOperator(minPrecedence)
    -- <binary> ::= <unary> <binary operator> <binary> | <unary>
    local expression = parseUnaryOperator()
    while isBinaryOperator(currentToken) do
      local precedence = getPrecedence(currentToken)
      if precedence <= minPrecedence and not isRightAssociativeBinaryOperator(currentToken) then
        -- The current operator has a lower precedence than the minimum precedence, so we stop parsing
        -- Right associative operators are an exception, because they can be chained.
        break
      end
      local operatorToken = currentToken
      if not consume() then -- Consume the operator
        error(generateError(ERROR_EXPECTED_EXPRESSION))
      end
      local right = parseBinaryOperator(precedence)
      expression = createOperatorNode(operatorToken.Value, expression, right)
    end
    return expression
  end

  --- Parses the unary operator.
  -- @return <Table> expression The AST of the unary operator.
  function parseUnaryOperator()
    -- <unary> ::= <unary operator> <unary> | <primary>
    if not isUnaryOperator(currentToken) then
      -- <primary>
      return parsePrimaryExpression()
    end
    -- <unary operator> <unary>
    local operator = currentToken.Value
    if not consume() then -- Consume the operator
      error(generateError(ERROR_EXPECTED_EXPRESSION))
    end

    local expression = parseUnaryOperator()
    return createUnaryOperatorNode(operator, expression)
  end

  --- Parses the primary expression.
  -- @return <Table> expression The AST of the primary expression.
  function parsePrimaryExpression()
    -- <primary> ::= <constant> | <variable> | <function call> | "(" <expression> ")"
    local token = currentToken
    if not token then return end

    local value = token.Value
    local TYPE = token.TYPE
    if TYPE == "Parentheses" and value == "(" then
      consume() -- Consume the opening parenthesis
      local expression = parseExpression()
      if not currentToken or currentToken.Value ~= ")" then
        error(generateError(ERROR_EXPECTED_CLOSING_PARENTHESIS))
      end
      consume() -- Consume the closing parenthesis
      return expression
    elseif TYPE == "Variable" then
      -- Check if it's a function call first
      if isFunctionCall() then
        return parseFunctionCall()
      end

      -- It's a variable
      consume()
      return token
    elseif TYPE == "Constant" then
      consume()
      return token
    end

    error(generateError(ERROR_UNEXPECTED_TOKEN, value))
  end

  --- Parses the expression.
  -- @return <Table> expression The AST of the expression.
  function parseExpression()
    local expression = parseBinaryOperator(0)
    return expression
  end

  --// PUBLIC METHODS \\--

  --- Resets the parser to its initial state so it can be reused.
  -- @param <Table> tokens The tokens to reset to.
  -- @param <Table?> operatorPrecedenceLevels=DEFAULT_OPERATOR_PRECEDENCE_LEVELS The operator precedence levels to reset to.
  local function resetToInitialState(givenTokens, givenOperatorPrecedenceLevels, givenTokenIndex, givenExpression)
    assert(givenTokens, ERROR_NO_TOKENS)

    tokens = givenTokens
    currentTokenIndex = givenTokenIndex or 1
    currentToken = givenTokens[currentTokenIndex]

    operatorPrecedenceLevels = givenOperatorPrecedenceLevels or DEFAULT_OPERATOR_PRECEDENCE_LEVELS
    charStream = (type(givenExpression) == "string" and stringToTable(givenExpression)) or givenExpression
  end

  --- Parses the given tokens, and returns the AST.
  -- @return <Table> expression The AST of the tokens.
  local function parse(noErrors)
    assert(tokens, ERROR_NO_TOKENS_TO_PARSE)

    local expression = parseExpression()
    if currentToken and not noErrors then
      error(generateError(ERROR_EXPECTED_EOF, currentToken.Value))
    end

    return expression
  end

  return {
    resetToInitialState = resetToInitialState,
    parse = parse
  }
end

return Parser