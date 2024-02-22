--[[
  Name: TokenFactory.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-02-19
  Description:
    This module contains the functions that will be
    Used to create tokens during the lexing process.
--]]

--* TokenFactory *--
local TokenFactory = {}

function TokenFactory:createConstantToken(value)
  return { TYPE = "Constant", Value = value, Position = self.curCharPos }
end
function TokenFactory:createVariableToken(value)
  return { TYPE = "Variable", Value = value, Position = self.curCharPos }
end
function TokenFactory:createParenthesesToken(value)
  return { TYPE = "Parentheses", Value = value, Position = self.curCharPos }
end
function TokenFactory:createOperatorToken(value)
  return { TYPE = "Operator", Value = value, Position = self.curCharPos }
end
function TokenFactory:createCommaToken()
  return { TYPE = "Comma", Position = self.curCharPos }
end

return TokenFactory