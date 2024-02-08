-- Dependencies
local MathParser = require("MathParser")

-- Create an instance of MathParser
local myMathParser = MathParser:new()

-- Solving a simple expression
local result = myMathParser:solve("2 + 3")
print(result)  -- Outputs: 5

-- Adding variables
myMathParser:addVariable("x", 10)
myMathParser:addVariable("y", 5)
result = myMathParser:solve("x + y")
print(result)  -- Outputs: 15

-- Adding functions
myMathParser:addFunction("add", function(a, b)
  return a + b
end)
result = myMathParser:solve("add(x, y)")
print(result)  -- Outputs: 15

-- Custom operators and precedence levels
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
    ["///"] = function(a, b) return 2 * (a / b) end
  }
}

myMathParser:setOperatorPrecedenceLevels(CUSTOM_OPERATOR_PRECEDENCE_LEVELS)
myMathParser:setOperators(CUSTOM_OPERATORS)
myMathParser:setOperatorFunctions(CUSTOM_OPERATOR_FUNCTIONS)

result = myMathParser:solve("10 ++ 10")
print(result)  -- Outputs: 40

result = myMathParser:solve("10 /// 10")
print(result)  -- Outputs: 2

-- Reset the parser to default settings
myMathParser:resetToInitialState()