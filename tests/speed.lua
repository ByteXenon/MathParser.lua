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
local expression = "1 + 2 + a + ab + sin(1)"

myMathParser:addVariable("a", 10)
myMathParser:addVariable("ab", 5)

local oldTime = os.clock()

for i = 1, 100000 do
  myMathParser:solve(expression)
end

local newTime = os.clock()

print("Time taken: " .. (newTime - oldTime) .. " seconds")

return true