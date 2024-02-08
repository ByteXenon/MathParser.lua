local MathParser = require("MathParser")

-- Create a new parser instance
local myParser = MathParser.new()

-- Add a new variable with the name "x" and the value 5
myParser:addVariable("x", 5)

-- Add a new function to the parser
myParser:addFunction("double", function(a) return a * 2 end)

-- Solve mathematical expressions
print(myParser:solve("x + 5")) -- Outputs: 10
print(myParser:solve("-double(x)")) -- Outputs: -10
print(myParser:solve("(1 + 2) * 2^3^2")) -- Outputs: 1536
