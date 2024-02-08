-- Dependencies
local MathParser = require("MathParser")

-- Create an instance of MathParser with default settings
local myMathParser = MathParser:new()

-- Solve a basic expression
local result = myMathParser:solve("2 + 2")
print(result) -- Outputs: 4

-- Now, let's add a variable
myMathParser:addVariable("x", 5)
result = myMathParser:solve("x + 2")
print(result) -- Outputs: 7

-- Add a function
myMathParser:addFunction("double", function(a) return a * 2 end)
result = myMathParser:solve("double(x) * 2")
print(result) -- Outputs: 20

-- Now, let's customize operator precedence and functions
local OPERATOR_PRECEDENCE_LEVELS = {
  Unary = { ["-"] = 2 },
  Binary = { ["+"] = 1, ["-"] = 1, ["++"] = 1 }
}

local OPERATOR_FUNCTIONS = {
  Unary = { ["-"] = function(a) return -a end },
  Binary = {
    ["+"] = function(a, b) return a + b end,
    ["-"] = function(a, b) return a - b end,
    ["++"] = function(a, b) return 2 * (a + b) end
  }
}

local VARIABLES, FUNCTIONS = {}, {}

-- When you add a custom operator, you have to also add it to the operators table
-- (Unary minus and normal minus signs are the same, so we don't need to add another "-" to the table)
local OPERATORS = { "+", "-", "++" }

myMathParser = MathParser:new(OPERATOR_PRECEDENCE_LEVELS, VARIABLES, OPERATOR_FUNCTIONS, OPERATORS, FUNCTIONS)
result = myMathParser:solve("2 ++ 2")
print(result) -- Outputs: 8