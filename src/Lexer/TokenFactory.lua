--[[
  Name: TokenFactory.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-01-07
  Description:
    This module contains the functions that will be
    Used to create tokens during the lexing process.
--]]

--* TokenFactory *--
local TokenFactory = {}

function TokenFactory.createConstantToken(value)
  return { TYPE = "Constant", Value = value }
end
function TokenFactory.createVariableToken(value)
  return { TYPE = "Variable", Value = value }
end
function TokenFactory.createParenthesesToken(value)
  return { TYPE = "Parentheses", Value = value }
end
function TokenFactory.createOperatorToken(value)
  return { TYPE = "Operator", Value = value }
end

return TokenFactory