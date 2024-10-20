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

--* MathParserMethods *--
local MathParserMethods = {}

--- Tokenizes the given expression.
-- @param <String> expression The expression to tokenize.
-- @return <Table> tokens The tokens of the expression.
function MathParserMethods:tokenize(expression)
  if self.cachedTokens[expression] then
    return self.cachedTokens[expression]
  end
  self.Lexer.resetToInitialState(expression, self.operators)
  local tokens = self.Lexer.run()
  self.cachedTokens[expression] = tokens
  return tokens
end

--- Parses the given tokens.
-- @param <Table> tokens The tokens to parse.
-- @return <Table> AST The AST of the tokens.
function MathParserMethods:parse(tokens, expression)
  if self.cachedASTs[expression] then
    return self.cachedASTs[expression]
  end
  self.Parser.resetToInitialState(tokens, self.operatorPrecedenceLevels, nil, expression)
  local AST = self.Parser.parse()
  self.cachedASTs[expression] = AST
  return AST
end

--- Evaluates the given AST.
-- @param <Table> AST The AST to evaluate.
-- @return <Number> evaluatedValue The result of the evaluation.
function MathParserMethods:evaluate(AST)
  if self.cachedResults[AST] then
    return self.cachedResults[AST]
  end
  self.Evaluator.resetToInitialState(AST, self.variables, self.operatorFunctions, self.functions)
  local evaluatedValue = self.Evaluator:evaluate()
  self.cachedResults[AST] = evaluatedValue
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
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds multiple variables to their values.
-- @param <Table> variables The variables to add.
function MathParserMethods:addVariables(variables)
  for variableName, variableValue in pairs(variables) do
    self:addVariable(variableName, variableValue)
  end
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds a function to the evaluator.
-- @param <String> functionName The name of the function.
-- @param <Function> functionValue The function to add.
function MathParserMethods:addFunction(functionName, functionValue)
  self.functions = self.functions or {}
  self.functions[functionName] = functionValue
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Adds multiple functions to the evaluator.
-- @param <Table> functions The functions to add.
function MathParserMethods:addFunctions(functions)
  for functionName, functionValue in pairs(functions) do
    self:addFunction(functionName, functionValue)
  end
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operator precedence levels that the parser will use.
-- @param <Table> operatorPrecedenceLevels The operator precedence levels to use in the parser.
function MathParserMethods:setOperatorPrecedenceLevels(operatorPrecedenceLevels)
  self.operatorPrecedenceLevels = operatorPrecedenceLevels
  -- Reset the cache so we won't get unexpected results
  self.cachedASTs = {}
end

--- Sets the variables that the evaluator will use.
-- @param <Table> variables The variables to use in the evaluator.
function MathParserMethods:setVariables(variables)
  self.variables = variables
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operator functions that the evaluator will use.
-- @param <Table> operatorFunctions The operator functions to evaluate in the evaluator.
function MathParserMethods:setOperatorFunctions(operatorFunctions)
  self.operatorFunctions = operatorFunctions
  -- Reset the cache so we won't get unexpected results
  self.cachedResults = {}
end

--- Sets the operators that the lexer will use.
-- @param <Table> operators The operators that the lexer will use.
function MathParserMethods:setOperators(operators)
  self.operators = operators
   -- Reset the cache so we won't get unexpected results
  self.cachedTokens = {}
end

--- Sets the functions that the evaluator will use.
-- @param <Table> functions The functions to use in the evaluator
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

  self.cachedTokens  = {}
  self.cachedASTs    = {}
  self.cachedResults = {}
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
  for key, value in pairs(MathParserMethods) do
    MathParserInstance[key] = value
  end

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
  MathParserInstance.Lexer = Lexer(nil, operators)
  MathParserInstance.Parser = Parser(nil, operatorPrecedenceLevels)
  MathParserInstance.Evaluator = Evaluator(nil, variables, operatorFunctions, functions)

  return MathParserInstance
end

return MathParser