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

--* Dependencies *--
local Evaluator = require("Evaluator/Evaluator")
local Lexer = require("Lexer/Lexer")
local Parser = require("Parser/Parser")

--* MathParserMethods *--
local MathParserMethods = {}

--- Tokenizes the given expression.
-- @param <String> expression The expression to tokenize.
-- @return <Table> tokens The tokens of the expression.
function MathParserMethods:tokenize(expression)
  self.Lexer:resetToInitialState(expression, self.operators)
  local tokens = self.Lexer:run()
  return tokens
end

--- Parses the given tokens.
-- @param <Table> tokens The tokens to parse.
-- @return <Table> AST The AST of the tokens.
function MathParserMethods:parse(tokens)
  self.Parser:resetToInitialState(tokens, self.operatorPrecedences)
  local AST = self.Parser:parse()
  return AST
end

--- Evaluates the given AST.
-- @param <Table> AST The AST to evaluate.
-- @return <Number> evaluatedValue The result of the evaluation.
function MathParserMethods:evaluate(AST)
  self.Evaluator:resetToInitialState(AST, self.variables, self.operatorFunctions)
  local evaluatedValue = self.Evaluator:evaluate()
  return evaluatedValue
end

--- Solves the given expression.
-- @param <String> expression The expression to solve.
-- @return <Number> result The result of the expression.
function MathParserMethods:solve(expression)
  return self:evaluate(self:parse(self:tokenize(expression)))
end

--- Sets a variable to its value.
-- @param <String> variableName The name of the variable.
-- @param <Number> variableValue The value of the variable.
function MathParserMethods:setVariable(variableName, variableValue)
  self.variables = self.variables or {}
  self.variables[variableName] = variableValue
end

--- Sets multiple variables to their values.
-- @param <Table> variables The variables to add.
function MathParserMethods:setVariables(variables)
  for variableName, variableValue in pairs(variables) do
    self:addVariable(variableName, variableValue)
  end
end

--* MathParser *--
local MathParser = {}

--- @class Creates a new MathParser.
-- @param <Table> operatorPrecedences The operator precedences to use in the parser.
-- @param <Table> variables The variables to use in the evaluator.
-- @param <Table> operatorFunctions The operator functions to evaluate in the evaluator.
-- @return <Table> MathParserInstance The MathParser instance.
function MathParser:new(operatorPrecedences, variables, operatorFunctions)
  local MathParserInstance = {}
  -- Properties
  MathParserInstance.operatorPrecedences = operatorPrecedences
  MathParserInstance.variables = variables
  MathParserInstance.operatorFunctions = operatorFunctions
  -- Classes
  MathParserInstance.Lexer = Lexer:new(nil)
  MathParserInstance.Parser = Parser:new(nil, operatorPrecedences)
  MathParserInstance.Evaluator = Evaluator:new(nil, variables, operatorFunctions)

  local function inheritModule(moduleName, moduleTable)
    for index, value in pairs(moduleTable) do
      if MathParserInstance[index] then
        return error("Conflicting names in " .. moduleName .. " and MathParserInstance: " .. index)
      end
      MathParserInstance[index] = value
    end
  end

  -- Main
  inheritModule("MathParserMethods", MathParserMethods)

  return MathParserInstance
end

-- Reset package.path
package.path = oldPath

return MathParser