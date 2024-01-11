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

local function runUnitTest(expression, expected, testName)
  local result = myMathParser:solve(expression)
  assert(result == expected, testName .. " failed. Expected: " .. expected .. ", Actual: " .. result)
  print("Successfully passed unit test: '" .. testName .. "' With result: " .. result)
end

-- Add some variables
myMathParser:addVariable("test", 10)
myMathParser:addVariable("a", 5)

-- Add some functions
myMathParser:addFunction("testFunction", function(a, b)
  return a + b
end)

-- Unit tests
runUnitTest("2 + 3", 5, "Addition")
runUnitTest("5 - 2", 3, "Subtraction")
runUnitTest("2 * 3", 6, "Multiplication")
runUnitTest("6 / 2", 3, "Division")
runUnitTest("2 ^ 3", 8, "Exponentiation")
runUnitTest("2 + 3 * 4", 14, "Operator precedence (multiplication)")
runUnitTest("2 ^ 3 ^ 2", 512, "Exponentiation (right-associative)")
runUnitTest("a + test", 15, "Variable substitution")
runUnitTest("(2 + 3) * 4 - 5", 15, "Complex expression")
runUnitTest("1.5 + 2.5", 4, "Floating point numbers")
runUnitTest(".5 + .5", 1, "Floating point numbers (leading decimal point)")
runUnitTest("2e3 + 2e+3", 4000, "Scientific notation (positive exponent)")
runUnitTest("2e3 - 2e-3", 1999.998, "Scientific notation (negative exponent)")
runUnitTest(".5e3 + .5e-3", 500.0005, "Scientific notation (leading decimal point)")
runUnitTest("1.10e+5", 110000, "Scientific notation (leading decimal point and positive exponent)")
runUnitTest("0xFF + 0xFF", 510, "Hexadecimal numbers")
runUnitTest("sin(1)", math.sin(1), "Function call (sin)")
runUnitTest("-sin(1)", -math.sin(1), "Function call (sin) with unary operator")
runUnitTest("sin(sin(1))", math.sin(math.sin(1)), "Function call (sin) with nested function call")
runUnitTest("log(10, 100)", math.log(10, 100), "Function call with multiple arguments (log)")
runUnitTest("log(sin(1), cos(1))", math.log(math.sin(1), math.cos(1)), "Function call (log) with multiple arguments-function-calls (sin, cos)")
runUnitTest("testFunction(2, 3)", 5, "Custom function call (testFunction)")

-- Error handling tests
local function runErrorHandlingTest(expression, testName)
  local status, err = pcall(function()
    myMathParser:solve(expression)
  end)
  assert(not status, testName .. " failed. Expected error, but got none, expression: " .. expression)
end

local invalidExpressions = {
  -- Lexer errors
  "~2", -- Unknown character
  "2~", -- Unknown character after number

  -- Parser errors
  "+ 2",     -- Missing left operand
  "2 +",     -- Missing right operand
  "2 + 3 +", -- Missing right operand after binary operator
  "-2-",     -- Missing operand after unary operator
  "--",      -- Missing operand after unary operator

  -- Evaluator errors
  "1 + unknownVariable",
  "1 + 2 + unknownVariable",
  "-unknownVariable",
  "sin(unknownVariable)",
  "unknownFunction(1)",
  "sin(1",
  "sin(1 + 2",
  "sin(1,)",
  "sin(1,"
}

for _, expression in ipairs(invalidExpressions) do
  runErrorHandlingTest(expression, "Error handling")
end

print("All unit tests passed!")

return true