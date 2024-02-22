--[[
  Name: Lexer.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-02-21
--]]

--* Dependencies *--
local Helpers = require("Helpers/Helpers")
local TokenFactory = require("Lexer/TokenFactory")

--* Constants *--
local ERROR_SEPARATOR = "+------------------------------+"

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
local createCommaToken       = TokenFactory.createCommaToken

--* Local functions *--

--- Creates a trie from the given operators, it's used to support 2+ character (potentional) operators.
-- @param <Table> table The operators to create the trie from.
-- @return <Table> trieTable The trie table.
-- @return <Number> longestElement The length of the longest operator.
local function makeTrie(table)
  local trieTable = {}
  local longestElement = 0

  for _, op in ipairs(table) do
    if #op > longestElement then
      longestElement = #op
    end

    local node = trieTable
    for index = 1, #op do
      local character = op:sub(index, index)
      node[character] = node[character] or {}
      node = node[character]
    end
    node.value = op
  end
  return trieTable, longestElement
end

--* Constants *--
local DEFAULT_OPERATORS = {"+", "-", "*", "/", "^", "%"}

--* LexerMethods *--
local LexerMethods = {}

--// PRIVATE METHODS \\--

--/ Helper methods /--

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

--/ Error handling /--

--- Generates an error message with a pointer to the current character.
-- @param <String> message The error message.
-- @param <Number?> positionAdjustment=0 The position adjustment to apply to the pointer.
-- @return <String> errorMessage The error message with a pointer.
function LexerMethods:generateErrorMessage(message, positionAdjustment)
  local position = self.curCharPos + (positionAdjustment or 0)
  local pointer = rep(" ", position - 1) .. "^"
  local errorMessage = "\n" .. concat(self.charStream) .. "\n" .. pointer .. "\n" .. message
  return errorMessage
end

--- Displays the error messages if there are any.
function LexerMethods:displayErrors()
  if #self.errors > 0 then
    local errorMessage = concat(self.errors, "\n" .. ERROR_SEPARATOR)
    error("Lexer errors:" .. "\n" .. ERROR_SEPARATOR .. errorMessage .. "\n" .. ERROR_SEPARATOR)
  end
end

--/ Character checks /--

--- Checks if the given character is a parenthesis.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isParenthesis Whether the character is a parenthesis.
function LexerMethods:isParenthesis(char)
  local char = (char or self.curChar)
  return char == "(" or char == ")"
end

--- Checks if the given character is a number.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isNumber Whether the character is a number.
function LexerMethods:isNumber(char)
  local char = (char or self.curChar)
  return char:match("[%d]") or (char == "." and self:peek():match("[%d]"))
end

--- Checks if the given character is a comma.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isComma Whether the character is a comma.
function LexerMethods:isComma(char)
  local char = (char or self.curChar)
  return char == ","
end

--- Checks if the given character is an identifier.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isIdentifier Whether the character is an identifier.
function LexerMethods:isIdentifier(char)
  local char = (char or self.curChar)
  return char:match("[a-zA-Z_]")
end

--- Checks if the given character is a whitespace.
-- @param <String?> char=self.curChar The character to check.
-- @return <Boolean> isWhitespace Whether the character is a whitespace.
function LexerMethods:isWhitespace(char)
  local char = (char or self.curChar)
  return char:match("%s")
end

--/ Token consumers /--

--- Consumes the next hexadecimal number from the character stream.
-- @param <Table> number The number character table to append the next number to.
-- @return <Table> number The parsed hexadecimal number.
function LexerMethods:consumeHexNumber(number)
  insert(number, self:consume()) -- consume the '0'
  local isHex = self:peek():match("[%da-fA-F]")
  if not isHex then
    insert(self.errors, self:generateErrorMessage("Expected a number after the 'x' or 'X'", 1))
  end
  repeat
    insert(number, self:consume())
    isHex = self:peek():match("[%da-fA-F]")
  until not isHex
  return number
end

--- Consumes the next floating point number from the character stream.
-- @param <Table> number The number character table to append the next number to.
-- @return <Tabel> number The parsed floating point number.
function LexerMethods:consumeFloatNumber(number)
  insert(number, self:consume()) -- consume the digit before the decimal point
  local isNumber = self:peek():match("[%d]")
  if not isNumber then
    insert(self.errors, self:generateErrorMessage("Expected a number after the decimal point", 1))
  end
  repeat
    insert(number, self:consume())
    isNumber = self:peek():match("[%d]")
  until not isNumber
  return number
end

--- Consumes the next number in scientific notation from the character stream.
-- @param <Table> number The number character table to append the next number to.
-- @return <Table> number The parsed number in scientific notation
function LexerMethods:consumeScientificNumber(number)
  insert(number, self:consume()) -- consume the digit before the exponent
  -- An optional sign, default: +
  if self:peek():match("[+-]") then
    -- consume the exponent sign, and insert the plus/minus sign
    insert(number, self:consume())
  end
  local isNumber = self:peek():match("[%d]")
  if not isNumber then
    insert(self.errors, self:generateErrorMessage("Expected a number after the exponent", 1))
  end

  repeat
    insert(number, self:consume())
    isNumber = self:peek():match("[%d]")
  until not isNumber
  return number
end

--- Consumes the next number from the character stream.
-- @return <String> number The next number.
function LexerMethods:consumeNumber()
  local number = {self.curChar}
  local isFloat = false
  local isScientific = false
  local isHex = false

  -- Check for hexadecimal numbers
  if self.curChar == '0' and (self:peek() == 'x' or self:peek() == 'X') then
    return concat(self:consumeHexNumber(number))
  end

  while self:peek():match("[%d]") do
    insert(number, self:consume())
  end

  -- Check for floating point numbers
  if self:peek() == "." then
    number = self:consumeFloatNumber(number)
  end

  -- Check for scientific notation
  if self:peek() == "e" or self:peek() == "E" then
    number = self:consumeScientificNumber(number)
  end

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
  if self:isNumber(self.curChar) then
    local newToken = self:consumeNumber()
    return createConstantToken(self, newToken)
  end

  local errorMessage = self:generateErrorMessage(
    "Invalid character detected: '" .. self.curChar
    .. "'. Expected one of the following: a whitespace, a parenthesis, a comma, an operator, or a number."
  )
  insert(self.errors, errorMessage)
  return
end

--- Consumes the next operator from the character stream.
-- @return <Table> operatorToken The next operator token.
function LexerMethods:consumeOperator()
  -- NOTE: Checking whether the current character is an operator is too expensive,
  --       so we use only this function to check if the current character is an operator.
  --       If it returns nil, then the current character is not an operator.
  local node = self.operatorsTrie
  local longestOperator = self.longestOperator
  local operator

  -- Trie walker
  for index = 0, longestOperator - 1 do
    -- Use peek() instead of consume() to avoid backtracking
    local character = self:peek(index)
    node = node[character] -- Advance to the deeper node
    if not node then break end
    if node.value then
      operator = node.value
    end
  end
  if operator then self:consume(#operator - 1) end

  return operator
end

--- Consumes the next token from the character stream.
-- @return <Table> token The next token.
function LexerMethods:consumeToken()
  local curChar = self.curChar
  -- We dont consume characters here if they're not operators
  local operator = self:consumeOperator()

  if self:isWhitespace(curChar) then
    -- Return nothing, so the token gets ignored and skipped
    return

  elseif operator then
    return createOperatorToken(self, operator)
  elseif self:isParenthesis(curChar) then
    return createParenthesesToken(self, curChar)
  elseif self:isIdentifier(curChar) then
    return createVariableToken(self, self:consumeIdentifier())
  elseif self:isComma(curChar) then
    return createCommaToken(self)
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
  self.operatorsTrie, self.longestOperator = makeTrie(self.operators)
end

--- Runs the lexer.
-- @return <Table> tokens The tokens of the expression.
function LexerMethods:run()
  self.errors = {}
  assert(self.charStream, "No charStream given")
  local tokens = self:consumeTokens()
  self:displayErrors()
  return tokens
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
  LexerInstance.operatorsTrie, LexerInstance.longestOperator = makeTrie(LexerInstance.operators)
  LexerInstance.errors = {}

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