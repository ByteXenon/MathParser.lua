--[[
  Name: MathParser.lua
  Author: ByteXenon [Luna Gilbert]
  Date: 2024-04-25
--]]

local scriptPath, requirePath, localPath, oldPath
if not LUAXEN_PACKER then
  -- Localize the path, so this file can be run from anywhere
  scriptPath = (debug.getinfo(1).source:match("@?(.*/)") or "")
  requirePath = scriptPath .. "./?.lua"
  localPath = scriptPath .. "./"
  oldPath = package.path
  package.path = package.path .. ";" .. requirePath
end

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
function MathParserMethods:parse(tokens, expression)
  self.Parser:resetToInitialState(tokens, self.operatorPrecedenceLevels, nil, expression)
  local AST = self.Parser:parse()
  return AST
end

--- Evaluates the given AST.
-- @param <Table> AST The AST to evaluate.
-- @return <Number> evaluatedValue The result of the evaluation.
function MathParserMethods:evaluate(AST)
  self.Evaluator:resetToInitialState(AST, self.variables, self.operatorFunctions, self.functions)
  local evaluatedValue = self.Evaluator:evaluate()
  return evaluatedValue
end

--- Solves the given expression.
-- @param <String> expression The expression to solve.
-- @return <Number> result The result of the expression.
function MathParserMethods:solve(expression)
  return self:evaluate(self:parse(self:tokenize(expression), expression))
end

--- Adds a variable to its value.
-- @param <String> variableName The name of the variable.
-- @param <Number> variableValue The value of the variable.
function MathParserMethods:addVariable(variableName, variableValue)
  self.variables = self.variables or {}
  self.variables[variableName] = variableValue
end

--- Adds multiple variables to their values.
-- @param <Table> variables The variables to add.
function MathParserMethods:addVariables(variables)
  for variableName, variableValue in pairs(variables) do
    self:addVariable(variableName, variableValue)
  end
end

--- Adds a function to the evaluator.
-- @param <String> functionName The name of the function.
-- @param <Function> functionValue The function to add.
function MathParserMethods:addFunction(functionName, functionValue)
  self.functions = self.functions or {}
  self.functions[functionName] = functionValue
end

--- Adds multiple functions to the evaluator.
-- @param <Table> functions The functions to add.
function MathParserMethods:addFunctions(functions)
  for functionName, functionValue in pairs(functions) do
    self:addFunction(functionName, functionValue)
  end
end

--- Sets the operator precedence levels that the parser will use.
-- @param <Table> operatorPrecedenceLevels The operator precedence levels to use in the parser.
function MathParserMethods:setOperatorPrecedenceLevels(operatorPrecedenceLevels)
  self.operatorPrecedenceLevels = operatorPrecedenceLevels
end

--- Sets the variables that the evaluator will use.
-- @param <Table> variables The variables to use in the evaluator.
function MathParserMethods:setVariables(variables)
  self.variables = variables
end

--- Sets the operator functions that the evaluator will use.
-- @param <Table> operatorFunctions The operator functions to evaluate in the evaluator.
function MathParserMethods:setOperatorFunctions(operatorFunctions)
  self.operatorFunctions = operatorFunctions
end

--- Sets the operators that the lexer will use.
-- @param <Table> operators The operators that the lexer will use.
function MathParserMethods:setOperators(operators)
  self.operators = operators
end

--- Sets the functions that the evaluator will use.
-- @param <Table> functions The functions to use in the evaluator
function MathParserMethods:setFunctions(functions)
  self.functions = functions
end

--- Resets the MathParser to its initial state.
-- @param <Table> operatorPrecedenceLevels The operator precedence levels to use in the parser.
-- @param <Table> variables The variables to use in the evaluator.
-- @param <Table> operatorFunctions The operator functions to evaluate in the evaluator.
-- @param <Table> operators The operators to use in the lexer.
-- @param <Table> functions The functions to use in the evaluator
function MathParserMethods:resetToInitialState(operatorPrecedenceLevels, variables, operatorFunctions, operators, functions)
  self.operatorPrecedenceLevels = operatorPrecedenceLevels
  self.variables = variables
  self.operatorFunctions = operatorFunctions
  self.operators = operators
  self.functions = functions
end

--* MathParser *--
local MathParser = {}

--- @class Creates a new MathParser.
-- @param <Table> operatorPrecedenceLevels The operator precedence levels to use in the parser.
-- @param <Table> variables The variables to use in the evaluator.
-- @param <Table> operatorFunctions The operator functions to evaluate in the evaluator.
-- @param <Table> operators The operators to use in the lexer.
-- @param <Table> functions The functions to use in the evaluator
-- @return <Table> MathParserInstance The MathParser instance.
function MathParser:new(operatorPrecedenceLevels, variables, operatorFunctions, operators, functions)
  local MathParserInstance = {}

  -- Properties
  MathParserInstance.operatorPrecedenceLevels = operatorPrecedenceLevels
  MathParserInstance.variables = variables
  MathParserInstance.operatorFunctions = operatorFunctions
  MathParserInstance.operators = operators
  MathParserInstance.functions = functions

  -- Classes
  MathParserInstance.Lexer = Lexer:new(nil, operators)
  MathParserInstance.Parser = Parser:new(nil, operatorPrecedenceLevels)
  MathParserInstance.Evaluator = Evaluator:new(nil, variables, operatorFunctions, functions)

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

if not LUAXEN_PACKER then
  -- Reset package.path
  package.path = oldPath
end

return MathParser
