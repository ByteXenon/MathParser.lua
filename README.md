# MathParser.lua - A Robust Lua Math Parser

> A comprehensive, user-friendly math parser for Lua, featuring support for variables and customizable operator precedence.

[![Lua Script Test](https://github.com/ByteXenon/MathParser.lua/actions/workflows/check-code.yaml/badge.svg)](https://github.com/ByteXenon/MathParser.lua/actions/workflows/check-code.yaml)


![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3%2C%205.4-blue?style=for-the-badge&logo=lua)
![GitHub stars](https://img.shields.io/github/stars/ByteXenon/MathParser.lua?style=for-the-badge)
![License](https://img.shields.io/github/license/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/ByteXenon/MathParser.lua?style=for-the-badge)

MathParser.lua is a math parser for Lua, designed with a focus on simplicity and elegance. Each function is meticulously documented, making the codebase easy to read and understand. It comes with a suite of unit tests, ensuring reliability and ease of use.

## Table of Contents:
- **[MathParser.lua](#mathparserlua---a-robust-lua-math-parser)**
  - **[Table of Contents](#table-of-contents)**
  - **[Features](#key-features)**
  - **[License](#license)**

**Quick Links:** **[API](./src/MathParser.lua)** | **[License](./LICENSE)** | **[Documentation](./docs/Documentation.md)**

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

-- Set the variable "x" to 5 
myParser:setVariable("x", 5)

-- Solve the expression "x + 5" and print the result 
print(myParser:solve("x + 5")) -- Outputs: 10
```

This is just a small sample of what MathParser.lua can do. For more information, check out the [documentation](docs/Documentation.md) or the source of the [API](src/MathParser.lua).

## License

MathParser.lua is licensed under the [AGPL-3.0 License](LICENSE).