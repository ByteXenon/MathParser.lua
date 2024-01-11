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

### `MathParserMethods:setVariable(variableName, variableValue)`
Sets a variable to its value. This allows you to use variables in your mathematical expressions.

Example:
```lua
MathParser:setVariable("x", 5)
local result = MathParser:solve("x + 2")
-- result: 7
```

### `MathParserMethods:setVariables(variables)`
Sets multiple variables to their values. This is a convenience method for setting multiple variables at once.

Example:
```lua
MathParser:setVariables({x = 5, y = 2})
local result = MathParser:solve("x + y")
-- result: 7
```

## Class

### `MathParser:new(operatorPrecedences, variables, operatorFunctions)`
Creates a new MathParser. You can specify operator precedences, variables, and operator functions to customize the behavior of the MathParser.

Example:
```lua
--* Dependencies *--
local MathParser = require("MathParser")

--* Constants *--
local OPERATOR_PRECEDENCES = {
  Unary = {
    -- Unary minus precedence
    ["-"] = 2
  },
  Binary = {
    ["+"] = 1,
    ["-"] = 1
  },
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

local VARIABLES = {
  x = 5
}

-- Create an instance of MathParser with custom operator precedences and functions
local myMathParser = MathParser:new(OPERATOR_PRECEDENCES, VARIABLES, OPERATOR_FUNCTIONS)
local result = myMathParser:solve("2 - 1 + --x")

print(result) -- Outputs: 6
```