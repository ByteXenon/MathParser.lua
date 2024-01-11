--[[
  Name: Helpers.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-01-10
--]]

--* Imports *--
local gmatch = string.gmatch
local insert = table.insert

--* Helpers *--
local Helpers = {}

--- Finds the given value in the given table.
-- @param <Table> table The table to search in.
-- @param <Any> value The value to search for.
-- @return <Any?> index The index of the value in the table.
function Helpers.tableFind(table, value)
  for index, tableValue in pairs(table) do
    if tableValue == value then
      return index
    end
  end
  return nil
end

--- Converts the given string to a table of its characters.
-- @param <String> string The string to convert.
-- @return <Table> table The table of characters.
function Helpers.stringToTable(string)
  local table = {}
  for char in gmatch(string, ".") do
    insert(table, char)
  end
  return table
end

return Helpers