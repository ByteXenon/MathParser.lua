--[[
  Name: TokenFactory.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-06-20
  Description:
    This module contains the functions that will be
    Used to create tokens during the lexing process.
--]]

--* TokenFactory *--
local TokenFactory = {}

function TokenFactory.createConstantToken(value, curCharPos)
  return { TYPE = "Constant", Value = value, Position = curCharPos }
end
function TokenFactory.createVariableToken(value, curCharPos)
  return { TYPE = "Variable", Value = value, Position = curCharPos }
end
function TokenFactory.createParenthesesToken(value, curCharPos)
  return { TYPE = "Parentheses", Value = value, Position = curCharPos }
end
function TokenFactory.createOperatorToken(value, curCharPos)
  return { TYPE = "Operator", Value = value, Position = curCharPos }
end
function TokenFactory.createCommaToken(curCharPos)
  return { TYPE = "Comma", Position = curCharPos }
end

return TokenFactory