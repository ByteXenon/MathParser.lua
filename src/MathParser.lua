--[[
  Name: MathParser.lua
  Author: ByteXenon
  Date: 2024-10-20
--]]

--* Dependencies *--
local Helpers   = require("Helpers/Helpers")
local Evaluator = require("Evaluator/Evaluator")
local Lexer     = require("Lexer/Lexer")
local Parser    = require("Parser/Parser")

--* Imports *--
local insertValues = Helpers.insertValues

--* MathParserMethods *--
local MathParserMethods = {}

--- Tokenizes the given expression.
--- @param expression string The expression to tokenize.
--- @return table tokens The tokens of the expression.
function MathParserMethods:tokenize(expression)
  if self.cachedTokens[expression] then
    return self.cachedTokens[expression]
  end
  self.Lexer:resetToInitialState(expression, self.operators)

  local tokens = self.Lexer:run()
  self.cachedTokens[expression] = tokens
  return tokens
end

--- Parses the given tokens.
--- @param tokens table The tokens to parse.
--- @param expression string The expression to parse.
--- @return table AST The AST of the tokens.
function MathParserMethods:parse(tokens, expression)
  if self.cachedASTs[expression] then
    return self.cachedASTs[expression]
  end
  self.Parser:resetToInitialState(tokens, self.operatorPrecedenceLevels, nil, expression)

  local AST = self.Parser:parse()
  self.cachedASTs[expression] = AST
  return AST
end

--- Evaluates the given AST.
--- @param AST table The AST to evaluate.
--- @return number evaluatedValue The result of the evaluation.
function MathParserMethods:evaluate(AST)
  if self.cachedResults[AST] then
    return self.cachedResults[AST]
  end

  self.Evaluator:resetToInitialState(AST, self.variables, self.operatorFunctions, self.functions)

  local evaluatedValue = self.Evaluator:evaluate()
  self.cachedResults[AST] = evaluatedValue
  return evaluatedValue
end

--- Solves the given expression.
--- @param expression string The expression to solve.
--- @return number result The result of the expression.
function MathParserMethods:solve(expression)
  return self:evaluate(self:parse(self:tokenize(expression), expression))
end

--- Adds a variable to its value.
--- @param variableName string The name of the variable.
--- @param variableValue number The value of the variable.
function MathParserMethods:addVariable(variableName, variableValue)
  self.variables = self.variables or {}
  self.variables[variableName] = variableValue

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds multiple variables to their values.
--- @param variables table The variables to add.
function MathParserMethods:addVariables(variables)
  for variableName, variableValue in pairs(variables) do
    self:addVariable(variableName, variableValue)
  end

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds a function to the evaluator.
--- @param functionName string The name of the function.
--- @param functionValue function The function to add.
function MathParserMethods:addFunction(functionName, functionValue)
  self.functions = self.functions or {}
  self.functions[functionName] = functionValue

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds multiple functions to the evaluator.
--- @param functions table The functions to add.
function MathParserMethods:addFunctions(functions)
  for functionName, functionValue in pairs(functions) do
    self:addFunction(functionName, functionValue)
  end

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operator precedence levels that the parser will use.
--- @param operatorPrecedenceLevels table The operator precedence levels to use in the parser.
function MathParserMethods:setOperatorPrecedenceLevels(operatorPrecedenceLevels)
  self.operatorPrecedenceLevels = operatorPrecedenceLevels

  -- Reset the cache so we won't get unexpected results
  self.cachedASTs = {}
end

--- Sets the variables that the evaluator will use.
--- @param variables table The variables to use in the evaluator.
function MathParserMethods:setVariables(variables)
  self.variables = variables

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operator functions that the evaluator will use.
--- @param operatorFunctions table The operator functions to evaluate in the evaluator.
function MathParserMethods:setOperatorFunctions(operatorFunctions)
  self.operatorFunctions = operatorFunctions

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operators that the lexer will use.
--- @param operators table The operators that the lexer will use.
function MathParserMethods:setOperators(operators)
  self.operators = operators

   -- Reset the cache so we won't get unexpected results
  self.cachedTokens = {}
end

--- Sets the functions that the evaluator will use.
--- @param functions table The functions to use in the evaluator.
function MathParserMethods:setFunctions(functions)
  self.functions = functions

  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Resets MathParser's caches.
function MathParserMethods:resetCaches()
  self.cachedTokens  = {}
  self.cachedASTs    = {}
  self.cachedResults = {}

  -- pcall() because if used in Roblox, it will throw an error
  pcall(collectgarbage, "collect") -- Free up memory from the old caches
end

--- Resets the MathParser to its initial state.
--- @param operatorPrecedenceLevels table? The operator precedence levels to use in the parser.
--- @param variables table? The variables to use in the evaluator.
--- @param operatorFunctions table? The operator functions to evaluate in the evaluator.
--- @param operators table? The operators to use in the lexer.
--- @param functions table? The functions to use in the evaluator.
function MathParserMethods:resetToInitialState(operatorPrecedenceLevels, variables, operatorFunctions, operators, functions)
  self.operatorPrecedenceLevels = operatorPrecedenceLevels
  self.variables = variables
  self.operatorFunctions = operatorFunctions
  self.operators = operators
  self.functions = functions

  self:resetCaches()
end

--* MathParser *--
local MathParser = {}

--- @class MathParserInstance
--- @param operatorPrecedenceLevels table? The operator precedence levels to use in the parser.
--- @param variables table? The variables to use in the evaluator.
--- @param operatorFunctions table? The operator functions to evaluate in the evaluator.
--- @param operators table? The operators to use in the lexer.
--- @param functions table? The functions to use in the evaluator.
--- @return table MathParserInstance The MathParser instance.
function MathParser:new(operatorPrecedenceLevels, variables, operatorFunctions, operators, functions)
  local MathParserInstance = {}

  -- Properties
  MathParserInstance.operatorPrecedenceLevels = operatorPrecedenceLevels
  MathParserInstance.variables = variables
  MathParserInstance.operatorFunctions = operatorFunctions
  MathParserInstance.operators = operators
  MathParserInstance.functions = functions

  -- Caches
  MathParserInstance.cachedTokens  = {}
  MathParserInstance.cachedASTs    = {}
  MathParserInstance.cachedResults = {}

  -- Classes
  MathParserInstance.Lexer     = Lexer.new(nil, operators)
  MathParserInstance.Parser    = Parser.new(nil, operatorPrecedenceLevels)
  MathParserInstance.Evaluator = Evaluator.new(nil, variables, operatorFunctions, functions)

  insertValues(MathParserMethods, MathParserInstance)

  return MathParserInstance
end

return MathParser