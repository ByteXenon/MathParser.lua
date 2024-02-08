# MathParser.lua Documentation

## Overview
`MathParser.lua` is a Lua module that provides functionality for parsing and evaluating mathematical expressions. It uses a Lexer, Parser, and Evaluator to tokenize, parse, and evaluate expressions respectively.

## Dependencies
- `Evaluator`: Evaluates the Abstract Syntax Tree (AST) of a mathematical expression.
- `Lexer`: Tokenizes a mathematical expression into a list of tokens.
- `Parser`: Parses a list of tokens into an AST.

## Methods

### `MathParserMethods:tokenize(expression)`
Tokenizes the given expression into a list of tokens. Each token represents a mathematical symbol or number.

Example:
```lua
local tokens = MathParser:tokenize("2 + 2")
-- tokens: { {TYPE = "Number", Value = "2"}, {TYPE = "Operator", Value = "+"}, {TYPE = "Number", Value = "2"} }
```

### `MathParserMethods:parse(tokens)`
Parses the given tokens into an Abstract Syntax Tree (AST). The AST represents the hierarchical structure of the mathematical expression.

Example:
```lua
local AST = MathParser:parse({ {TYPE = "Number", Value = "2"}, {TYPE = "Operator", Value = "+"}, {TYPE = "Number", Value = "2"} })
-- AST: { TYPE = "Operator", Value = "+", Left = { TYPE = "Number", Value = "2" }, Right = { TYPE = "Number", Value = "2" } }
```

### `MathParserMethods:evaluate(AST)`
Evaluates the given AST and returns the result of the mathematical expression.

Example:
```lua
local result = MathParser:evaluate({ TYPE = "Operator", Value = "+", Left = { TYPE = "Number", Value = "2" }, Right = { TYPE = "Number", Value = "2" } })
-- result: 4
```

### `MathParserMethods:solve(expression)`
Solves the given expression by tokenizing, parsing, and evaluating it. This is a convenience method that combines the tokenize, parse, and evaluate methods.

Example:
```lua
local result = MathParser:solve("2 + 2")
-- result: 4
```

### `MathParserMethods:addVariable(variableName, variableValue)`
Adds a variable and sets its value.

Example:
```lua
MathParser:addVariable("x", 5)
local result = MathParser:solve("x + 2")
-- result: 7
```

### `MathParserMethods:addVariables(variables)`
Adds multiple variables and sets their values.

Example:
```lua
MathParser:addVariables({x = 5, y = 2})
local result = MathParser:solve("x + y")
-- result: 7
```

### `MathParserMethods:addFunction(functionName, functionValue)`
Adds a function to the parser, allowing it to be used in mathematical expressions.

Example:
```lua
MathParser:addFunction("double", function(a) return a * 2 end)
local result = MathParser:solve("double(5)")
-- result: 10
```

### `MathParserMethods:addFunctions(functions)`
Adds multiple functions to the parser, allowing them to be used in mathematical expressions.

Example:
```lua
MathParser:addFunctions({double = function(a) return a * 2 end, triple = function(a) return a * 3 end})
local result = MathParser:solve("double(5) + triple(5)")
-- result: 25
```

## Class

### `MathParser:new(operatorPrecedenceLevels, variables, operatorFunctions, operators, functions)`
Creates a new MathParser. You can specify operator precedence levels, variables, operator functions, operators, and functions. If you don't specify any of these, the default values will be used.

Example:
```lua
--* Dependencies *--
local MathParser = require("MathParser")

--* Constants *--
local OPERATOR_PRECEDENCE_LEVELS = {
  Unary = {
    -- Unary minus precedence
    ["-"] = 2
  },
  Binary = {
    ["+"] = 1,
    ["-"] = 1
  },
}

local VARIABLES = {
  x = 5
}

local OPERATOR_FUNCTIONS = {
  Unary = {
    ["-"] = function(a) return -a end,
  },
  Binary = {
    ["+"] = function(a, b) return a + b end,
    ["-"] = function(a, b) return a - b end
  }
}

local OPERATORS = { "-", "+" }

local FUNCTIONS = {
  double = function(a) return a * 2 end
}

-- Create an instance of MathParser with custom operator precedence levels and functions
local myMathParser = MathParser:new(OPERATOR_PRECEDENCE_LEVELS, VARIABLES, OPERATOR_FUNCTIONS, OPERATORS, FUNCTIONS)
local result = myMathParser:solve("2 - -x + double(2)")

print(result) -- Outputs: 11
```