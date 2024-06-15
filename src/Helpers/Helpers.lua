--[[
  Name: Helpers.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-06-14
--]]

--* Imports *--
local char   = string.char
local match  = string.match
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

--- Converts a pattern to a character lookup table.
-- @param <String> pattern The pattern to convert.
-- @return <Table> table The table of characters.
function Helpers.createPatternLookupTable(pattern)
  local lookupTable = {}
  for i = 0, 255 do
    local character = char(i)
    if match(character, pattern) then
      lookupTable[character] = true
    end
  end
  return lookupTable
end

--- Creates a trie from the given operators, it's used to support 2+ character (potentional) operators.
-- @param <Table> table The operators to create the trie from.
-- @return <Table> trieTable The trie table.
function Helpers.makeTrie(table)
  local trieTable = {}

  for _, op in ipairs(table) do
    local node = trieTable
    for index = 1, #op do
      local character = op:sub(index, index)
      node[character] = node[character] or {}
      node = node[character]
    end
    node.value = op
  end
  return trieTable
end

return Helpers