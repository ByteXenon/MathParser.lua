--[[
  Math Parser Tests
--]]

-- Localize the path, so this file can be run from anywhere
local scriptPath = (debug.getinfo(1).source:match("@?(.*/)") or "")
local requirePath = scriptPath .. "../src/?.lua"
local localPath = scriptPath .. "../src/"
package.path = requirePath

-- Dependencies
local MathParser = require("MathParser")

-- Create an instance of MathParser
local myMathParser = MathParser:new()

local errorMessages = {}
local successMessages = {}

local function runUnitTest(expression, expected, testName)
  local result = myMathParser:solve(expression)
  if result ~= expected then
    table.insert(errorMessages, testName .. " failed. Expected: " .. expected .. ", Actual: " .. result .. ", Expression: " .. expression)
  end
  table.insert(successMessages, "Successfully passed unit test: '" .. testName .. "' With result: " .. result)
end
local function displaySuccessMessages()
  if #successMessages > 0 then
    print(table.concat(successMessages, "\n") .. "")
  end
end
local function displayErrorMessages()
  if #errorMessages > 0 then
    error(table.concat(errorMessages, "\n") .. "")
  end
end

-- Add some variables
myMathParser:addVariable("test", 10)
myMathParser:addVariable("a", 5)

-- Register the variables as locals so we can use it in Lua too
local test = 10
local a = 5

-- Add some functions
myMathParser:addFunction("testFunction", function(a, b)
  return a + b
end)


--// UNIT TESTS //--

-- Basic tests
runUnitTest("1 + 1", 1+1, "Addition")
runUnitTest("2 * 2", 2*2, "Subtraction")
runUnitTest("1 * 2", 1*2, "Multiplication")
runUnitTest("2 / 1", 2/1, "Division")
runUnitTest("1 ^ 2", 1^2, "Exponentiation")
runUnitTest("1 + 1 * 2", 1+1*2, "Operator precedence (multiplication)")
runUnitTest("1 ^ 1 ^ 2", 1^1^2, "Exponentiation (right-associative)")
runUnitTest("a + test", a+test, "Variable substitution")
runUnitTest("(1 + 1) * 2 - 1", (1+1)*2-1, "Complex expression")
runUnitTest("1.0 + 1.5", 1.0+1.5, "Floating point numbers")
runUnitTest(".5 + .5", .5+.5, "Floating point numbers (leading decimal point)")
runUnitTest("1e1 + 1e+1", 1e1+1e+1, "Scientific notation (positive exponent)")
runUnitTest("1e1 - 1e-1", 1e1-1e-1, "Scientific notation (negative exponent)")
runUnitTest(".5e1 + .5e-1", .5e1+.5e-1, "Scientific notation (leading decimal point)")
runUnitTest("1.10e+1", 1.10e+1, "Scientific notation (leading decimal point and positive exponent)")
runUnitTest(".5e1 + 1.5e+1 + 2.5e-1", .5e1+1.5e+1+2.5e-1, "Advanced scientific notation (leading decimal point)")
runUnitTest("0xF + 0xF", 0xF+0xF, "Hexadecimal numbers")
runUnitTest("sin(1)", math.sin(1), "Function call (sin)")
runUnitTest("-sin(1)", -math.sin(1), "Function call (sin) with unary operator")
runUnitTest("sin(sin(1))", math.sin(math.sin(1)), "Function call (sin) with nested function call")
runUnitTest("log(1, 10)", math.log(1, 10), "Function call with multiple arguments (log)")
runUnitTest("log(sin(1), cos(1))", math.log(math.sin(1), math.cos(1)), "Function call (log) with multiple arguments-function-calls (sin, cos)")
runUnitTest("testFunction(1, 1)", 1+1, "Custom function call (testFunction)")

-- Operator Precedence Tests
runUnitTest("2+3*4", 2+3*4, "Operator precedence (multiplication before addition)")
runUnitTest("2*3+4", 2*3+4, "Operator precedence (multiplication before addition)")
runUnitTest("2-3*4", 2-3*4, "Operator precedence (multiplication before subtraction)")
runUnitTest("2*3-4", 2*3-4, "Operator precedence (multiplication before subtraction)")
runUnitTest("2+3/4", 2+3/4, "Operator precedence (division before addition)")
runUnitTest("2/3+4", 2/3+4, "Operator precedence (division before addition)")
runUnitTest("2-3/4", 2-3/4, "Operator precedence (division before subtraction)")
runUnitTest("2/3-4", 2/3-4, "Operator precedence (division before subtraction)")
runUnitTest("2+3^4", 2+3^4, "Operator precedence (exponentiation before addition)")
runUnitTest("2^3+4", 2^3+4, "Operator precedence (exponentiation before addition)")
runUnitTest("2-3^4", 2-3^4, "Operator precedence (exponentiation before subtraction)")
runUnitTest("2^3-4", 2^3-4, "Operator precedence (exponentiation before subtraction)")
runUnitTest("2*3^4", 2*3^4, "Operator precedence (exponentiation before multiplication)")
runUnitTest("2^3*4", 2^3*4, "Operator precedence (exponentiation before multiplication)")
runUnitTest("2/3^4", 2/3^4, "Operator precedence (exponentiation before division)")
runUnitTest("2^3/4", 2^3/4, "Operator precedence (exponentiation before division)")
runUnitTest("(2+3)*4", (2+3)*4, "Parentheses change precedence")
runUnitTest("-2", -2, "Unary minus operator")
runUnitTest("-2^3", -2^3, "Unary minus operator precedence with exponentiation")
runUnitTest("-(2^3)", -(2^3), "Unary minus operator precedence with parentheses and exponentiation")
runUnitTest("-2*3", -2*3, "Unary minus operator precedence with multiplication")
runUnitTest("-(2*3)", -(2*3), "Unary minus operator precedence with parentheses and multiplication")
runUnitTest("-2/3", -2/3, "Unary minus operator precedence with division")
runUnitTest("-(2/3)", -(2/3), "Unary minus operator precedence with parentheses and division")
runUnitTest("-2+3", -2+3, "Unary minus operator precedence with addition")
runUnitTest("-(2+3)", -(2+3), "Unary minus operator precedence with parentheses and addition")
runUnitTest("-2-3", -2-3, "Unary minus operator precedence with subtraction")
runUnitTest("-(2-3)", -(2-3), "Unary minus operator precedence with parentheses and subtraction")
runUnitTest("- -2", - -2, "Double unary minus operator")
runUnitTest("-2+3*4^5-6/7", -2+3*4^5-6/7, "Complex expression with all operators and no parentheses")
runUnitTest("-2+(3*4)^(5- -6)/7", -2+(3*4)^(5- -6)/7, "Complex expression with all operators and parentheses")


-- Advanced tests
local CUSTOM_OPERATOR_PRECEDENCE_LEVELS = {
  Unary = { ["-"] = 3 },
  Binary = { ["+"] = 1, ["-"] = 1, ["++"] = 1, ["///"] = 2, ["/"] = 2 }
}
local CUSTOM_OPERATORS = { "+", "-", "++", "///", "/" }
local CUSTOM_OPERATOR_FUNCTIONS = {
  Unary = { ["-"] = function(a) return -a end },
  Binary = {
    ["+"] = function(a, b) return a + b end,
    ["-"] = function(a, b) return a - b end,
    ["/"] = function(a, b) return a / b end,

    -- Custom operators
    ["++"] = function(a, b) return 2 * (a + b) end,
    -- Instead of "//", I used "///" to check how the trie node traversal works
    ["///"] = function(a, b) return 2 * (a / b) end
  }
}

myMathParser:setOperatorPrecedenceLevels(CUSTOM_OPERATOR_PRECEDENCE_LEVELS)
myMathParser:setOperators(CUSTOM_OPERATORS)
myMathParser:setOperatorFunctions(CUSTOM_OPERATOR_FUNCTIONS)

runUnitTest("10 ++ 10", 40, "Custom operator precedence (++)")
runUnitTest("10 /// 10", 2, "Custom operator precedence (///)")
runUnitTest("10 / 10", 1, "Custom (normal) operator precedence (/)")
runUnitTest("10 + 10", 20, "Custom (normal) operator precedence (+)")

-- Reset the parser to default settings
myMathParser:resetToInitialState()

-- Error handling tests
local function runErrorHandlingTest(expression, testName)
  local status, err = pcall(function()
    myMathParser:solve(expression)
  end)
  assert(not status, testName .. " failed. Expected error, but got none, expression: " .. expression)
end

local invalidExpressions = {
  -- Lexer errors
  "~2",    -- Contains an unknown character '~' before a number.
  "2~",    -- Contains an unknown character '~' after a number.
  ".",     -- Only a decimal point without any digits.
  "1.",    -- Missing digits after the decimal point.
  "1e",    -- Exponential notation missing an exponent.
  "1e+",   -- Exponential notation missing an exponent after the sign.
  "0x",    -- Hexadecimal notation missing digits.
  "1..2",  -- Contains multiple decimal points in a number.
  "0xG",   -- Contains an invalid hexadecimal digit 'G'.
  "1e-+2", -- Exponential notation with an invalid sign combination.

  -- Parser errors
  "+ 2",       -- Unary plus operator missing its left operand.
  "2 +",       -- Binary plus operator missing its right operand.
  "2 + 3 +",   -- Binary plus operator missing its right operand after another operator.
  "-2-",       -- Unary minus operator missing its right operand.
  "--",        -- Double unary minus operators missing their operand.
  "2 + 3)",    -- Unmatched right parenthesis.
  "(2 + 3",    -- Unmatched left parenthesis.
  "sin(,)",    -- Function call missing all arguments.
  "sin(1,,1)", -- Function call with missing argument between commas.
  "sin(1,)",   -- Function call missing second argument after comma.
  "sin(,1)",   -- Function call missing first argument before comma.
  "sin(1,2",   -- Function call missing closing parenthesis.
  "sin(1,",    -- Function call missing closing parenthesis and second argument.
  "sin(",      -- Function call missing closing parenthesis and argument.
  "()",        -- Empty parentheses without any expression.
  "sin()",     -- Function call without any arguments.
  "2 **",      -- Unexpected operator after multiplication operator.
  "2 * / 3",   -- Missing operand between multiplication and division operators.

  -- Evaluator errors
  "1 + unknownVariable",  -- Expression contains an undefined variable.
  "-unknownVariable",     -- Unary minus applied to an undefined variable.
  "sin(unknownVariable)", -- Function call with an undefined variable as argument.
  "unknownFunction(1)",   -- Call to an undefined function.
}

for _, expression in ipairs(invalidExpressions) do
  runErrorHandlingTest(expression, "Error handling")
end

displayErrorMessages()
displaySuccessMessages()
print("All unit tests passed!")

return true