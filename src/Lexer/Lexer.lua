--[[
  Name: Lexer.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-06-20
--]]

--* Dependencies *--
local Helpers      = require("Helpers/Helpers")
local TokenFactory = require("Lexer/TokenFactory")

--* Imports *--
local makeTrie                 = Helpers.makeTrie
local stringToTable            = Helpers.stringToTable
local createPatternLookupTable = Helpers.createPatternLookupTable

local concat = table.concat
local insert = table.insert
local rep    = string.rep

local createConstantToken    = TokenFactory.createConstantToken
local createVariableToken    = TokenFactory.createVariableToken
local createParenthesesToken = TokenFactory.createParenthesesToken
local createOperatorToken    = TokenFactory.createOperatorToken
local createCommaToken       = TokenFactory.createCommaToken

--* Constants *--
local ERROR_SEPARATOR = "+------------------------------+"

local ERROR_NUMBER_AFTER_X             = "Expected a number after the 'x' or 'X'"
local ERROR_NUMBER_AFTER_DECIMAL_POINT = "Expected a number after the decimal point"
local ERROR_NUMBER_AFTER_EXPONENT_SIGN = "Expected a number after the exponent sign"
local ERROR_INVALID_CHARACTER          = "Invalid character '%s'. Expected whitespace, parenthesis, comma, operator, or number."
local ERROR_NO_CHAR_STREAM             = "No charStream given"

local DEFAULT_OPERATORS      = {"+", "-", "*", "/", "^", "%"}
local DEFAULT_OPERATORS_TRIE = makeTrie(DEFAULT_OPERATORS)

local WHITESPACE_LOOKUP              = createPatternLookupTable("%s")
local NUMBER_LOOKUP                  = createPatternLookupTable("%d")
local IDENTIFIER_LOOKUP              = createPatternLookupTable("[a-zA-Z_]")
local HEXADECIMAL_NUMBER_LOOKUP      = createPatternLookupTable("[%da-fA-F]")
local PLUS_MINUS_LOOKUP              = createPatternLookupTable("[+-]")
local SCIENTIFIC_E_LOOKUP            = createPatternLookupTable("[eE]")
local HEXADECIMAL_X_LOOKUP           = createPatternLookupTable("[xX]")
local IDENTIFIER_CONTINUATION_LOOKUP = createPatternLookupTable("[a-zA-Z0-9_]")
local PARENTHESIS_LOOKUP             = createPatternLookupTable("[()]")

--* Lexer *--
--- @class Creates a new Lexer.
-- @param <String?> expression The expression to tokenize.
-- @param <Table?> operators=DEFAULT_OPERATORS The operators to use.
-- @param <Number?> charPos=1 The character position to start at.
-- @return <Table> LexerInstance The Lexer instance.
local function Lexer(expression, operators, charPos)
  local errors = {}
  local charStream, curChar, curCharPos
  if expression then
    expression = expression .. "\0"
    charStream = stringToTable(expression)
    curChar    = charStream[charPos or 1]
    curCharPos = charPos or 1
  end
  local operatorTrie       = (operators and makeTrie(operators)) or DEFAULT_OPERATORS_TRIE
  local operators          = operators or DEFAULT_OPERATORS
  local operatorsTrie      = operatorTrie
  local stringToTableCache = {}

  --/ Helper methods /--

  --- Gets the next character from the character stream.
  -- @return <String> char The next character.
  local function peek()
    return charStream[curCharPos + 1]
  end

  --- Consumes the next character from the character stream.
  -- @param <Number?> n=1 The amount of characters to go ahead.
  -- @return <String> char The next character.
  local function consume(n)
    local newCurCharPos = curCharPos + (n or 1)
    local newCurChar    = charStream[newCurCharPos]
    curCharPos = newCurCharPos
    curChar    = newCurChar
    return newCurChar
  end

  --/ Error handling /--

  --- Generates an error message with a pointer to the current character.
  -- @param <String> message The error message.
  -- @param <Number?> positionAdjustment=0 The position adjustment to apply to the pointer.
  -- @return <String> errorMessage The error message with a pointer.
  local function generateErrorMessage(message, positionAdjustment)
    local position     = curCharPos + (positionAdjustment or 0)
    local pointer      = rep(" ", position - 1) .. "^"
    local errorMessage = "\n" .. concat(charStream) .. "\n" .. pointer .. "\n" .. message
    return errorMessage
  end

  --- Displays the error messages if there are any.
  local function displayErrors()
    local errors = errors
    if #errors > 0 then
      local errorMessage = concat(errors, "\n" .. ERROR_SEPARATOR)
      error("Lexer errors:" .. "\n" .. ERROR_SEPARATOR .. errorMessage .. "\n" .. ERROR_SEPARATOR)
    end
  end

  --/ Character checks /--

  --- Checks if the given character is a number.
  -- @param <String?> char=curChar The character to check.
  -- @return <Boolean> isNumber Whether the character is a number.
  local function isNumber(char)
    local char = (char or curChar)
    return NUMBER_LOOKUP[char] or (char == "." and NUMBER_LOOKUP[peek()])
  end

  --/ Token consumers /--

  --- Consumes the next hexadecimal number from the character stream.
  -- @param <Table> number The number character table to append the next number to.
  -- @return <Table> number The parsed hexadecimal number.
  local function consumeHexNumber(number)
    insert(number, consume()) -- consume the '0'
    local isHex = HEXADECIMAL_NUMBER_LOOKUP[peek()]
    if not isHex then
      local generatedErrorMessage = generateErrorMessage(ERROR_NUMBER_AFTER_X, 1)
      insert(errors, generatedErrorMessage)
    end
    repeat
      insert(number, consume())
      isHex = HEXADECIMAL_NUMBER_LOOKUP[peek()]
    until not isHex
    return number
  end

  --- Consumes the next floating point number from the character stream.
  -- @param <Table> number The number character table to append the next number to.
  -- @return <Tabel> number The parsed floating point number.
  local function consumeFloatNumber(number)
    insert(number, consume()) -- consume the digit before the decimal point
    local isNumber = NUMBER_LOOKUP[peek()]
    if not isNumber then
      local generatedErrorMessage = generateErrorMessage(ERROR_NUMBER_AFTER_DECIMAL_POINT, 1)
      insert(errors, generatedErrorMessage)
    end
    repeat
      insert(number, consume())
      isNumber = NUMBER_LOOKUP[peek()]
    until not isNumber
    return number
  end

  --- Consumes the next number in scientific notation from the character stream.
  -- @param <Table> number The number character table to append the next number to.
  -- @return <Table> number The parsed number in scientific notation
  local function consumeScientificNumber(number)
    insert(number, consume()) -- consume the digit before the exponent
    -- An optional sign, default: +
    if PLUS_MINUS_LOOKUP[peek()] then
      -- consume the exponent sign, and insert the plus/minus sign
      insert(number, consume())
    end
    local isNumber = NUMBER_LOOKUP[peek()]
    if not isNumber then
      local generatedErrorMessage = generateErrorMessage(ERROR_NUMBER_AFTER_EXPONENT_SIGN, 1)
      insert(errors, generatedErrorMessage)
    end

    repeat
      insert(number, consume())
      isNumber = NUMBER_LOOKUP[peek()]
    until not isNumber
    return number
  end

  --- Consumes the next number from the character stream.
  -- @return <String> number The next number.
  local function consumeNumber()
    local number       = { curChar }
    local isFloat      = false
    local isScientific = false
    local isHex        = false

    -- Check for hexadecimal numbers
    if curChar == '0' and HEXADECIMAL_X_LOOKUP[peek()] then
      return concat(consumeHexNumber(number))
    end

    while NUMBER_LOOKUP[peek()] do
      insert(number, consume())
    end

    -- Check for floating point numbers
    if peek() == "." then
      number = consumeFloatNumber(number)
    end

    -- Check for scientific notation
    local nextChar = peek()
    if SCIENTIFIC_E_LOOKUP[nextChar] then
      number = consumeScientificNumber(number)
    end

    return concat(number)
  end

  --- Consumes the next identifier from the character stream.
  -- @return <String> identifier The next identifier.
  local function consumeIdentifier()
    local identifier, identifierLen = {}, 0
    local nextChar
    repeat
      identifierLen = identifierLen + 1
      identifier[identifierLen] = curChar
      local nextChar = peek()
    until not (IDENTIFIER_CONTINUATION_LOOKUP[nextChar] and consume())
    -- Use table.concat instead of the .. operator, because it's faster.
    return concat(identifier)
  end

  --- Consumes the next constant from the character stream.
  -- @return <Table> constantToken The next constant token.
  local function consumeConstant()
    -- <number>
    if isNumber(curChar) then
      local newToken = consumeNumber()
      return createConstantToken(newToken, curCharPos)
    end

    local errorMessage = generateErrorMessage(ERROR_INVALID_CHARACTER:format(curChar))
    insert(errors, errorMessage)
    return
  end

  --- Consumes the next operator from the character stream.
  -- @return <Table> operatorToken The next operator token.
  local function consumeOperator()
    local node       = operatorsTrie
    local charStream = charStream
    local curCharPos = curCharPos
    local operator

    -- Trie walker
    local index = 0
    while true do
      -- Use raw charStream instead of peek() for performance reasons
      local character = charStream[curCharPos + index]
      node = node[character] -- Advance to the deeper node
      if not node then break end
      operator = node.value
      index = index + 1
    end
    if operator then
      consume(#operator - 1)
    end

    return operator
  end

  --- Consumes the next token from the character stream.
  -- @return <Table> token The next token.
  local function consumeToken()
    local curChar = curChar

    if WHITESPACE_LOOKUP[curChar] then
      -- Return nothing, so the token gets ignored and skipped
      return
    elseif PARENTHESIS_LOOKUP[curChar] then
      return createParenthesesToken(curChar, curCharPos)
    elseif IDENTIFIER_LOOKUP[curChar] then
      return createVariableToken(consumeIdentifier(), curCharPos)
    elseif curChar == "," then
      return createCommaToken(curCharPos)
    else
      local operator = consumeOperator()
      if operator then
        return createOperatorToken(operator, curCharPos)
      end
      return consumeConstant()
    end
  end

  --- Consumes all the tokens from the character stream.
  -- @return <Table> tokens The tokens.
  local function consumeTokens()
    local tokens, tokensLen = {}, 0

    local curChar = curChar
    while curChar ~= "\0" do
      local newToken = consumeToken()
      -- Since whitespaces returns nothing, we have to check if the token is not nil to insert it.
      if newToken then
        tokensLen = tokensLen + 1
        tokens[tokensLen] = newToken
      end
      curChar = consume()
    end

    return tokens
  end

  --// PUBLIC METHODS \\--

  --- Resets the lexer to its initial state.
  -- @param <String?> expression The character stream to reset to.
  -- @param <Table?> givenOperators=DEFAULT_OPERATORS The operators to reset to.
  local function resetToInitialState(expression, givenOperators)
    -- If charStream is a string convert it to a table of characters
    if expression then
      expression = expression .. "\0"
      charStream = stringToTableCache[expression] or stringToTable(expression)
      curChar    = charStream[1]
      curCharPos = 1

      stringToTableCache[expression] = charStream
    end

    operatorsTrie = (givenOperators and makeTrie(givenOperators)) or DEFAULT_OPERATORS_TRIE
    operators     = givenOperators or DEFAULT_OPERATORS
  end

  --- Runs the lexer.
  -- @return <Table> tokens The tokens of the expression.
  local function run()
    assert(charStream, ERROR_NO_CHAR_STREAM)
    errors = {}
    local tokens = consumeTokens()

    displayErrors()
    return tokens
  end

  return {
    resetToInitialState = resetToInitialState,
    run = run
  }
end

return Lexer