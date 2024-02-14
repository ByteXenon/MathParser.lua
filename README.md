# MathParser.lua - A Robust Lua Math Parser

> A comprehensive, user-friendly math parser for Lua, featuring support for variables, functions and customizable operator precedence.

![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3%2C%205.4-blue?style=for-the-badge&logo=lua)
![GitHub stars](https://img.shields.io/github/stars/ByteXenon/MathParser.lua?style=for-the-badge)
![License](https://img.shields.io/github/license/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/ByteXenon/MathParser.lua?style=for-the-badge)
![Tests Passing](https://img.shields.io/badge/Tests-Passing-green?style=for-the-badge)
![100% Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-green?style=for-the-badge)

MathParser.lua is a robust and comprehensive math parser for Lua, designed with a focus on simplicity, elegance, and user-friendliness. Each function in the codebase is well-documented, making it easy to read, understand, and modify. It supports a wide range of mathematical operations, from basic arithmetic to complex expressions, and allows for the addition of custom functions, variables, operators, and operator precedence levels.

This project boasts a full 100% test coverage. It has been thoroughly tested and confirmed to work seamlessly on Lua versions 5.1, 5.2, 5.3, 5.4, as well as on LuaJIT and Luau.

## Table of Contents:
- **[MathParser.lua](#mathparserlua---a-robust-lua-math-parser)**
  - **[Table of Contents](#table-of-contents)**
  - **[Features](#features)**
  - **[Usage](#usage)**
    - **[Basic Usage](#basic-usage)**
    - **[Advanced Usage](#advanced-usage)**
  - **[License](#license)**

**Quick Links:** **[API](./src/MathParser.lua)** | **[License](./LICENSE)** | **[Documentation](./docs/Documentation.md)** | **[Example](./example.lua)**

## Features

- **Simplicity**: MathParser.lua offers a user-friendly [API](./src/MathParser.lua) that is easy to understand and use.
- **Lightweight**: Despite its powerful features, MathParser.lua is lightweight and has no external dependencies.
- **Efficient**: MathParser.lua is also optimized for speed, ensuring fast computations even with complex mathematical expressions.
- **Customizable**: With MathParser.lua, you have the flexibility to modify operator precedence and add new operators, tailoring the parser to your specific needs.

## Usage

Here's a quick guide on how to use MathParser.lua:

### Basic Usage

```lua
local MathParser = require("MathParser")

-- Create a new parser instance
local myParser = MathParser:new()

-- Add a new variable with the name "x" and the value 5
myParser:addVariable("x", 5)

-- Solve a simple mathematical expression
print(myParser:solve("x + 5")) -- Outputs: 10

-- Solve a more complex expression
print(myParser:solve("(x + 5) * 2")) -- Outputs: 20
```

### Advanced Usage

In addition to basic arithmetic, MathParser.lua supports custom functions and operators. Here's an example of how to use these features:

```lua
local MathParser = require("MathParser")

-- Create a new parser instance
local myParser = MathParser:new()

-- Add a new variable with the name "x" and the value 5
myParser:addVariable("x", 5)

-- Add a new function to the parser
myParser:addFunction("double", function(a) return a * 2 end)

-- Solve a mathematical expression using the custom function
print(myParser:solve("-double(x)")) -- Outputs: -10

-- Custom operators and precedence levels
-- https://en.wikipedia.org/wiki/Operator_associativity
local CUSTOM_OPERATOR_PRECEDENCE_LEVELS = {
  -- The lower the precedence level, the lower the priority of the operator
  Unary = { ["-"] = 3 },
  Binary = { ["^"] = 2, ["+"] = 1, ["-"] = 1 },
  RightAssociativeBinaryOperators = {
    ["^"] = true
  }
}

-- The behavior of the operators can be customized
local CUSTOM_OPERATOR_FUNCTIONS = {
  Unary = { ["-"] = function(a) return -a end },
  Binary = {
    -- Make the power operator behave like the XOR operator
    ["^"] = function(a, b) return (a + b) % 2 end,

    -- Make the addition operator behave like the subtraction operator, and vice versa
    ["+"] = function(a, b) return a - b end,
    ["-"] = function(a, b) return a + b end
  }
}

myParser:setOperatorPrecedenceLevels(CUSTOM_OPERATOR_PRECEDENCE_LEVELS)
myParser:setOperatorFunctions(CUSTOM_OPERATOR_FUNCTIONS)

print(myParser:solve("5 - 3")) -- Outputs: 8
print(myParser:solve("5 + 3")) -- Outputs: 2
print(myParser:solve("5 ^ 3")) -- Outputs: 0
```

This is just a small sample of what MathParser.lua can do. For more information, check out the [documentation](docs/Documentation.md), the source of the [API](src/MathParser.lua), or the [example usage](./example.lua).

## License

MathParser.lua is (re)licensed under the [MIT License](LICENSE).