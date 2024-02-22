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
  "~2", -- Unknown character before number
  "2~", -- Unknown character after number
  ".", -- Missing digits after decimal point
  "1.", -- Missing digits after decimal point
  "1e", -- Missing exponent
  "1e+", -- Missing exponent value
  "0x", -- Missing hexadecimal digits

  -- Parser errors
  "+ 2",     -- Missing left operand
  "2 +",     -- Missing right operand
  "2 + 3 +", -- Missing right operand after binary operator
  "-2-",     -- Missing operand after unary operator
  "--",      -- Missing operand after unary operator
  "2 + 3)",  -- Missing left parenthesis
  "(2 + 3",  -- Missing right parenthesis
  -- "sin" is one of default functions
  "sin(,)",    -- Missing arguments in function call
  "sin(1,,1)", -- Missing argument in-between in function call
  "sin(1,)",   -- Missing second argument in function call
  "sin(,1)",   -- Missing first argument in function call
  "sin(1,2",   -- Missing right parenthesis in function call
  "sin(1,",    -- Missing right parenthesis in function call

  -- Evaluator errors
  "1 + unknownVariable",
  "-unknownVariable",
  "sin(unknownVariable)",
  "unknownFunction(1)",
}

for _, expression in ipairs(invalidExpressions) do
  runErrorHandlingTest(expression, "Error handling")
end

displayErrorMessages()
displaySuccessMessages()
print("All unit tests passed!")

return true