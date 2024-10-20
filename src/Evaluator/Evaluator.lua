--[[
  Name: Evaluator.lua
  Author: ByteXenon
  Date: 2024-10-20
--]]

--* Imports *--
local unpack = (unpack or table.unpack)
local insert = table.insert

--* Constants *--
local DEFAULT_OPERATOR_FUNCTIONS = {
  Unary = {
    ["-"] = function(operand) return -operand end
  },
  Binary = {
    ["+"] = function(left, right) return left + right end,
    ["-"] = function(left, right) return left - right end,
    ["/"] = function(left, right) return left / right end,
    ["*"] = function(left, right) return left * right end,
    ["^"] = function(left, right) return left ^ right end,
    ["%"] = function(left, right) return left % right end
  }
}

local DEFAULT_FUNCTIONS = {
  sin   = math.sin,   cos   = math.cos,
  tan   = math.tan,   asin  = math.asin,
  acos  = math.acos,  atan  = math.atan,
  floor = math.floor, ceil  = math.ceil,
  abs   = math.abs,   sqrt  = math.sqrt,
  log   = math.log,   log10 = math.log10,
  exp   = math.exp,   rad   = math.rad,
  deg   = math.deg
}

--* Evaluator *--
--- @class Creates a new Evaluator instance.
-- @param <Table> expression The expression to evaluate.
-- @param <Table?> variables={} The variables to use in the evaluator.
-- @param <Table?> operatorFunctions=DEFAULT_OPERATOR_FUNCTIONS The operator functions to evaluate in the evaluator.
-- @param <Table?> functions=DEFAULT_FUNCTIONS The functions to evaluate in the evaluator.
-- @return <Table> Evaluator The Evaluator instance.
local function Evaluator(expression, variables, operatorFunctions, functions)
  local expression = expression
  local variables = variables or {}
  local operatorFunctions = operatorFunctions or DEFAULT_OPERATOR_FUNCTIONS
  local functions = functions or {}

  local evaluateUnaryOperator, evaluateBinaryOperator,
        evaluateOperator, evaluateFunctionCall, evaluateNode

  --- Evaluates the given unary operator node.
  -- @param <Table> node The node to evaluate.
  -- @return <Number> result The result of the evaluation.
  function evaluateUnaryOperator(node)
    local nodeValue = node.Value

    local operatorFunction = operatorFunctions.Unary[nodeValue]
    assert(operatorFunction, "invalid operator: " .. tostring(nodeValue))

    local operandValue = evaluateNode(node.Operand)
    return operatorFunction(operandValue, node)
  end

  --- Evaluates the given binary operator node.
  -- @param <Table> node The node to evaluate.
  -- @return <Number> result The result of the evaluation.
  function evaluateBinaryOperator(node)
    local nodeValue = node.Value
    local nodeLeft = node.Left
    local nodeRight = node.Right

    local operatorFunction = operatorFunctions.Binary[nodeValue]
    assert(operatorFunction, "invalid operator")

    local leftValue = evaluateNode(nodeLeft)
    local rightValue = evaluateNode(nodeRight)
    return operatorFunction(leftValue, rightValue, node)
  end

  --- Check what type of operator node it is and evaluates it by calling the appropriate function.
  -- @param <Table> node The node to evaluate.
  -- @return <Number> result The result of the evaluation.
  function evaluateOperator(node)
    local isUnary = not (not node.Operand)
    if isUnary then
      return evaluateUnaryOperator(node)
    end
    return evaluateBinaryOperator(node)
  end

  --- Evaluates a function call node.
  -- @param <Table> node The node to evaluate.
  -- @return <Number> result The result of the evaluation.
  function evaluateFunctionCall(node)
    local functionName = node.FunctionName
    local arguments = node.Arguments

    local functionCall = functions[functionName] or DEFAULT_FUNCTIONS[functionName]
    assert(functionCall, "invalid function call: " .. tostring(functionName))

    local evaluatedArguments = {}
    for _, argument in ipairs(arguments) do
      local evaluatedArgument = evaluateNode(argument)
      insert(evaluatedArguments, evaluatedArgument)
    end

    return functionCall(unpack(evaluatedArguments))
  end

  --- Evaluates the given node.
  -- @param <Table> node The node to evaluate.
  -- @return <Number> result The result of the evaluation.
  function evaluateNode(node)
    local nodeType = node.TYPE

    if nodeType == "Constant" then
      return tonumber(node.Value)
    elseif nodeType == "Variable" then
      local variableValue = variables[node.Value]
      if not variableValue then
        return error("Variable not found: " .. tostring(node.Value))
      end
      return variableValue
    elseif nodeType == "Operator" or nodeType == "UnaryOperator" then
      return evaluateOperator(node)
    elseif nodeType == "FunctionCall" then
      return evaluateFunctionCall(node)
    end

    return error("Invalid node type: " .. tostring(nodeType) .. " ( You're not supposed to see this error message. )")
  end

  --// PUBLIC METHODS \\--

  --- Resets the evaluator to its initial state.
  -- @param <Table> givenExpression The expression to evaluate.
  -- @param <Table?> givenVariables={} The variables to use in the evaluator.
  -- @param <Table?> givenOperatorFunctions=DEFAULT_OPERATOR_FUNCTIONS The operator functions to evaluate in the evaluator.
  -- @param <Table?> givenFunctions=DEFAULT_FUNCTIONS The functions to evaluate in the evaluator.
  local function resetToInitialState(givenExpression, givenVariables, givenOperatorFunctions, givenFunctions)
    expression        = givenExpression
    variables         = givenVariables or {}
    operatorFunctions = givenOperatorFunctions or DEFAULT_OPERATOR_FUNCTIONS
    functions         = givenFunctions or DEFAULT_FUNCTIONS
  end

  --- Evaluates the given expression.
  -- @return <Number> result The result of the evaluation.
  local function evaluate()
    assert(expression, "No expression to evaluate")
    return evaluateNode(expression)
  end

  return {
    resetToInitialState = resetToInitialState,
    evaluate = evaluate
  }
end

return Evaluator