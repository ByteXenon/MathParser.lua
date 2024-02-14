# MathParser.lua - A Robust Lua Math Parser

> A comprehensive, user-friendly math parser for Lua, featuring support for variables, functions and customizable operator precedence.

![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3%2C%205.4-blue?style=for-the-badge&logo=lua)
![GitHub stars](https://img.shields.io/github/stars/ByteXenon/MathParser.lua?style=for-the-badge)
![License](https://img.shields.io/github/license/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/ByteXenon/MathParser.lua?style=for-the-badge)
![Tests Passing](https://img.shields.io/badge/Tests-Passing-green?style=for-the-badge)
![100% Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-green?style=for-the-badge)

MathParser.lua is a robust and comprehensive math parser for Lua, designed with a focus on simplicity, elegance, and user-friendliness. Each function in the codebase is meticulously documented, making it easy to read, understand, and modify. It supports a wide range of mathematical operations, from basic arithmetic to complex expressions, and allows for the addition of custom functions and variables, providing flexibility and adaptability to suit your specific needs.

It comes with a suite of unit tests, ensuring reliability and ease of use.

## Table of Contents:
- **[MathParser.lua](#mathparserlua---a-robust-lua-math-parser)**
  - **[Table of Contents](#table-of-contents)**
  - **[Features](#features)**
  - **[License](#license)**

**Quick Links:** **[API](./src/MathParser.lua)** | **[License](./LICENSE)** | **[Documentation](./docs/Documentation.md)** | **[Example](./example.lua)**

## Features

- **Simplicity**: MathParser.lua offers a user-friendly interface that's easy to use and understand.
- **Lightweight**: Despite its powerful features, MathParser.lua maintains a small footprint, making it a lightweight addition to any project.
- **Efficient**: MathParser.lua is optimized for speed, ensuring fast computations even with complex mathematical expressions.
- **Customizable**: With MathParser.lua, you have the flexibility to modify operator precedence and add new operators, tailoring the parser to your specific needs.

## Usage

Here's a quick guide on how to use MathParser.lua:

```lua
local MathParser = require("MathParser")

-- Create a new parser instance
local myParser = MathParser.new()

-- Add a new variable with the name "x" and the value 5
myParser:addVariable("x", 5)

-- Add a new function to the parser
myParser:addFunction("double", function(a) return a * 2 end)

-- Solve mathematical expressions
print(myParser:solve("x + 5")) -- Outputs: 10
print(myParser:solve("-double(x)")) -- Outputs: -10
print(myParser:solve("(1 + 2) * 2^3^2")) -- Outputs: 1536
```

This is just a small sample of what MathParser.lua can do. For more information, check out the [documentation](docs/Documentation.md), the source of the [API](src/MathParser.lua), or the [example usage](./example.lua).

## License

MathParser.lua is (re)licensed under the [MIT License](LICENSE).