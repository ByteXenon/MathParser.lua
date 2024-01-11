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

-- Create an instance of MathParser with custom variables
local myMathParser = MathParser:new(nil, VARIABLES)

-- Add some variables
myMathParser:setVariable("test", 10)
myMathParser:setVariable("a", 5)

-- Unit tests
local function runUnitTest(expression, expected, testName)
  local result = myMathParser:solve(expression)
  assert(result == expected, testName .. " failed. Expected: " .. expected .. ", Actual: " .. result)
  print("Successfully passed unit test: '" .. testName .. "' With result: " .. result)
end

runUnitTest("2 + 3", 5, "Addition")
runUnitTest("5 - 2", 3, "Subtraction")
runUnitTest("2 * 3", 6, "Multiplication")
runUnitTest("6 / 2", 3, "Division")
runUnitTest("2 ^ 3", 8, "Exponentiation")
runUnitTest("2 ^ 3 ^ 2", 512, "Exponentiation (right-associative)")
runUnitTest("a + test", 15, "Variable substitution")
runUnitTest("(2 + 3) * 4 - 5", 15, "Complex expression")

-- Error handling tests
local function runErrorHandlingTest(expression, testName)
  local status, err = pcall(function()
    myMathParser:solve(expression)
  end)
  assert(not status, testName .. " failed. Expected an error, but no error occurred.")
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
}

for _, expression in ipairs(invalidExpressions) do
  runErrorHandlingTest(expression, "Error handling")
end

print("All unit tests passed!")

return true