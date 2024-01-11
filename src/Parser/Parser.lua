--[[
  Name: Parser.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-01-10
--]]

--* Constants *--
local DEFAULT_OPERATOR_PRECEDENCES = {
  Unary = {
    -- Unary minus precedence
    ["-"] = 4
  },
  Binary = {
    ["^"] = 3,
    ["*"] = 2,
    ["/"] = 2,
    ["%"] = 2,
    ["+"] = 1,
    ["-"] = 1
  },
  RightAssociativeBinaryOperators = {
    ["^"] = true
  }
}

--* Local Functions *--
local function createUnaryOperatorNode(operator, operand)
  return { TYPE = "UnaryOperator", Value = operator, Operand = operand }
end
local function createOperatorNode(operator, left, right)
  return { TYPE = "Operator", Value = operator, Left = left, Right = right }
end

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
  self.currentTokenIndex = self.currentTokenIndex + (n or 1)
  self.currentToken = self.tokens[self.currentTokenIndex]
  return self.currentToken
end

--- Checks if the given token is a binary operator.
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isBinaryOperator Whether the token is a binary operator.
function ParserMethods:isBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedences.Binary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedences.Binary[token.Value]
end

--- Checks if the given token is an unary operator.
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isUnaryOperator Whether the token is an unary operator.
function ParserMethods:isUnaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedences.Unary then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedences.Unary[token.Value]
end

--- Checks if the given token is a right associative binary operator.
-- @param <Table?> token=self.currentToken The token to check.
-- @return <Boolean> isRightAssociativeBinaryOperator Whether the token is a right associative binary operator.
function ParserMethods:isRightAssociativeBinaryOperator(token)
  local token = token or self.currentToken
  if not self.operatorPrecedences.RightAssociativeBinaryOperators then return end
  return token and token.TYPE == "Operator" and self.operatorPrecedences.RightAssociativeBinaryOperators[token.Value]
end

--- Gets the precedence of the given token.
-- @param <Table> token The token to get the precedence of.
-- @return <Number> precedence The precedence of the token.
function ParserMethods:getPrecedence(token)
  return token and self.operatorPrecedences.Binary[token.Value]
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

    self:consume() -- Consume the operator
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
  self:consume() -- Consume the operator
  local expression = self:parseUnaryOperator()
  return createUnaryOperatorNode(operator, expression)
end

--- Parses the primary expression.
-- @return <Table> expression The AST of the primary expression.
function ParserMethods:parsePrimaryExpression()
  -- <primary> ::= <constant> | <variable> | "(" <expression> ")"
  local token = self.currentToken
  if not token then return end

  local value = token.Value
  local TYPE = token.TYPE
  if TYPE == "Parentheses" and value == "(" then
    self:consume() -- Consume the opening parenthesis
    local expression = self:parseExpression()
    if not self.currentToken or self.currentToken.Value ~= ")" then
      error("Mismatched parentheses")
    end
    self:consume() -- Consume the closing parenthesis
    return expression
  elseif TYPE == "Constant" or TYPE == "Variable" then
    self:consume()
    return token
  end

  error("Unexpected token: '" .. value .. "'")
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
-- @param <Table?> operatorPrecedences=DEFAULT_OPERATOR_PRECEDENCES The operator precedences to reset to.
function ParserMethods:resetToInitialState(tokens, operatorPrecedences)
  assert(tokens, "No tokens given")

  self.tokens = tokens
  self.currentToken = tokens[1]
  self.currentTokenIndex = 1

  self.operatorPrecedences = operatorPrecedences or DEFAULT_OPERATOR_PRECEDENCES
end

--- Parses the given tokens, and returns the AST.
-- @return <Table> expression The AST of the tokens.
function ParserMethods:parse()
  assert(self.tokens, "No tokens to parse")

  local expression = self:parseExpression()
  local remainingToken = self.currentToken
  if remainingToken then
    error("Invalid expression: unexpected token '" .. remainingToken.Value .. "'")
  end

  return expression
end

--* Parser *--
local Parser = {}

--- @class Creates a new Parser instance
-- @param <Table> tokens The tokens to parse
-- @param <Table?> operatorPrecedences=DEFAULT_OPERATOR_PRECEDENCES The operator precedences to use in the parser
-- @param <Number?> tokenIndex=1 The index of the current token
-- @return <Table> ParserInstance The Parser instance
function Parser:new(tokens, operatorPrecedences, tokenIndex)
  local ParserInstance = {}
  if tokens then
    ParserInstance.tokens = tokens
    ParserInstance.currentTokenIndex = tokenIndex or 1
    ParserInstance.currentToken = tokens[ParserInstance.currentTokenIndex]
  end
  ParserInstance.operatorPrecedences = operatorPrecedences or DEFAULT_OPERATOR_PRECEDENCES

  local function inheritModule(moduleName, moduleTable)
    for index, value in pairs(moduleTable) do
      if ParserInstance[index] then
        return error("Conflicting names in " .. moduleName .. " and ParserInstance: " .. index)
      end
      ParserInstance[index] = value
    end
  end

  -- Main
  inheritModule("ParserMethods", ParserMethods)

  return ParserInstance
end

return Parser