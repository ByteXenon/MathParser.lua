local args = {...}
local version = args[1]

local rockspec = [[
package = "MathParser"
version = "]]..version..[["
source = {
  url = "https://github.com/ByteXenon/MathParser.lua/archive/v]]..version..[[.tar.gz"
}
description = {
  summary = "A math parser for Lua.",
  detailed = "An elegant Math Parser written in Lua, featuring support for adding custom operators and functions.",
  homepage = "https://github.com/ByteXenon/MathParser.lua",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["MathParser"] = "MathParser.min.lua"
  }
}
]]

local file = io.open("MathParser-"..version..".rockspec", "w")
file:write(rockspec)
file:close()