--[[
  Name: Lexer.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-01-10
--]]

--* Dependencies *--
local Helpers = require("Helpers/Helpers")
local TokenFactory = require("Lexer/TokenFactory")

--* Imports *--
local stringToTable = Helpers.stringToTable
local find = (table.find or Helpers.tableFind)
local concat = table.concat
local insert = table.insert
local rep = string.rep

local createConstantToken    = TokenFactory.createConstantToken
local createVariableToken    = TokenFactory.createVariableToken
local createParenthesesToken = TokenFactory.createParenthesesToken
local createOperatorToken    = TokenFactory.createOperatorToken

--* Constants *--
local DEFAULT_OPERATORS = {"+", "-", "*", "/", "^", "%"}

--* LexerMethods *--
local LexerMethods = {}

--// PRIVATE METHODS \\--

--- Gets the next character from the character stream.
-- @param <Number?> n=1 The amount of characters to skip in order to get the next character.
-- @return <String> char The next character.
function LexerMethods:peek(n)
  return self.charStream[self.curCharPos + (n or 1)] or "\0"
end

--- Consumes the next character from the character stream.
-- @param <Number?> n=1 The amount of characters to go ahead.
-- @return <String> char The next character.
function LexerMethods:consume(n)
  self.curCharPos = self.curCharPos + (n or 1)
  self.curChar = self.charStream[self.curCharPos] or "\0"
  return self.curChar
end

--- Generates an error message with a pointer to the current character.
-- @param <String> message The error message.
-- @return <String> errorMessage The error message with a pointer.
function LexerMethods:generateError(message)
  local pointer = rep(" ", self.curCharPos - 1) .. "^"
  local errorMessage = "\n" .. concat(self.charStream) .. "\n" .. pointer .. "\n" .. message
  return errorMessage
end

--- Checks if the given character is a parenthesis.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isParenthesis Whether the character is a parenthesis.
function LexerMethods:isParenthesis(char)
  local char = (char or self.curChar)
  return char == "(" or char == ")"
end

--- Checks if the given character is a digit.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isDigit Whether the character is a digit.
function LexerMethods:isDigit(char)
  return (char or self.curChar):match("%d")
end

--- Checks if the given character is an identifier.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isIdentifier Whether the character is an identifier.
function LexerMethods:isIdentifier(char)
  return (char or self.curChar):match("[a-zA-Z_]")
end

--- Checks if the given character is a whitespace.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isWhitespace Whether the character is a whitespace.
function LexerMethods:isWhitespace(char)
  return (char or self.curChar):match("%s")
end

--- Consumes the next number from the character stream.
-- @return <String> number The next number.
function LexerMethods:consumeNumber()
  local number = {}
  local nextChar
  repeat
    insert(number, self.curChar)
    nextChar = self:peek()
  until not (nextChar:match("%d") and self:consume())
  -- Use table.concat instead of the .. operator, because it's faster.
  return concat(number)
end

--- Consumes the next identifier from the character stream.
-- @return <String> identifier The next identifier.
function LexerMethods:consumeIdentifier()
  local identifier = {}
  local nextChar
  repeat
    insert(identifier, self.curChar)
    local nextChar = self:peek()
  until not (nextChar:match("[a-zA-Z0-9_]") and self:consume())
  -- Use table.concat instead of the .. operator, because it's faster.
  return concat(identifier)
end

--- Consumes the next constant from the character stream.
-- @return <Table> constantToken The next constant token.
function LexerMethods:consumeConstant()
  -- <number>
  if self:isDigit() then
    local newToken = self:consumeNumber()
    return createConstantToken(newToken)
  end

  local errorMessage = self:generateError(
    "Unexpected character: '" .. self.curChar
    .. "', expected one of: {<whitespace>, <parentheses>, <operator>, <number>}"
  )
  error(errorMessage)
  return
end

--- Consumes the next token from the character stream.
-- @return <Table> token The next token.
function LexerMethods:consumeToken()
  local curChar = self.curChar

  if self:isWhitespace() then
    -- Return nothing, so the token gets ignored and skipped
    return
  elseif self:isParenthesis() then
    return createParenthesesToken(curChar)
  elseif self:isIdentifier() then
    return createVariableToken(self:consumeIdentifier())
  elseif find(self.operators, curChar) then
    return createOperatorToken(curChar)
  else
    return self:consumeConstant()
  end
end

--- Consumes all the tokens from the character stream.
-- @return <Table> tokens The tokens.
function LexerMethods:consumeTokens()
  local tokens = {}

  -- Optimization to not index the "self" table every time in the while loop.
  local curChar = self.curChar

  while curChar ~= "\0" do
    local newToken = self:consumeToken()
    -- Since whitespaces return nothing, we have to check if the token is not nil to insert it.
    if newToken then
      insert(tokens, newToken)
    end

    curChar = self:consume()
  end

  return tokens
end

--// PUBLIC METHODS \\--

--- Resets the lexer to its initial state.
-- @param <Table> charStream The character stream to reset to.
-- @param <Table?> operators=DEFAULT_OPERATORS The operators to reset to.
function LexerMethods:resetToInitialState(charStream, operators)
  assert(charStream, "No charStream given")

  -- If charStream is a string convert it to a table of characters
  self.charStream = (type(charStream) == "string" and stringToTable(charStream)) or charStream
  self.curChar = (self.charStream[1]) or "\0"
  self.curCharPos = 1

  self.operators = operators or DEFAULT_OPERATORS
end

--- Runs the lexer.
-- @return <Table> tokens The tokens of the expression.
function LexerMethods:run()
  assert(self.charStream, "No charStream given")
  return self:consumeTokens()
end

--* Lexer (Tokenizer) *--
local Lexer = {}

--- @class Creates a new Lexer.
-- @param <String|Table> expression The expression to tokenize.
-- @param <Table?> operators=DEFAULT_OPERATORS The operators to use.
-- @param <Number?> charPos=1 The character position to start at.
-- @return <Table> LexerInstance The Lexer instance.
function Lexer:new(expression, operators, charPos)
  local LexerInstance = {}
  if expression then
    LexerInstance.charStream = (type(expression) == "string" and stringToTable(expression)) or expression
    LexerInstance.curChar = (LexerInstance.charStream[charPos or 1]) or "\0"
    LexerInstance.curCharPos = charPos or 1
  end
  LexerInstance.operators = operators or DEFAULT_OPERATORS

  local function inheritModule(moduleName, moduleTable)
    for index, value in pairs(moduleTable) do
      if LexerInstance[index] then
        return error("Conflicting names in " .. moduleName .. " and LexerInstance: " .. index)
      end
      LexerInstance[index] = value
    end
  end

  -- Main
  inheritModule("LexerMethods", LexerMethods)

  return LexerInstance
end

return Lexer