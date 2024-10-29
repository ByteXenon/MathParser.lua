--[[
  Name: Helpers.lua
  Author: ByteXenon
  Date: 2024-10-20
--]]

--* Imports *--
local strChar   = string.char
local strMatch  = string.match
local strGmatch = string.gmatch
local tbInsert  = table.insert

--* Helpers *--
local Helpers = {}

--- Converts the given string to a table of its characters.
-- @param <String> string The string to convert.
-- @return <Table> table The table of characters.
function Helpers.stringToTable(string)
  local table = {}
  for char in strGmatch(string, ".") do
    tbInsert(table, char)
  end
  return table
end

--- Converts a pattern to a character lookup table.
-- @param <String> pattern The pattern to convert.
-- @return <Table> table The table of characters.
function Helpers.createPatternLookupTable(pattern)
  local lookupTable = {}
  for i = 0, 255 do
    local character = strChar(i)
    if strMatch(character, pattern) then
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
    for character in op:gmatch(".") do
      node[character] = node[character] or {}
      node = node[character]
    end
    node.value = op
  end

  return trieTable
end

--- Inserts values from the source table into the destination table.
-- @param <Table> source The source table.
-- @param <Table> destination The destination table.
function Helpers.insertValues(source, destination)
  for key, value in pairs(source) do
    if destination[key] then
      error("Key already exists in destination table: " .. key)
    end

    destination[key] = value
  end
end

return Helpers