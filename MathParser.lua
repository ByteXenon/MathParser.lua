--[[
  Name: MathParser.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-01-10
--]]

-- Localize the path, so this file can be run from anywhere
local scriptPath = (debug.getinfo(1).source:match("@?(.*/)") or "")
local requirePath = scriptPath .. "./?.lua"
local localPath = scriptPath .. "./"
local oldPath = package.path
package.path = package.path .. ";" .. requirePath

local MathParser = require("src/MathParser")

-- Reset package.path
package.path = oldPath

return MathParser