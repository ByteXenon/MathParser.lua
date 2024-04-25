<div align="center">

<img src="https://github.com/ByteXenon/MathParser.lua/assets/125568681/7c85601d-1218-414b-9545-f5e57d48c061" alt="MathParser.lua logo" width="200" height="200">

# MathParser.lua - A Robust Lua Math Parser

A comprehensive, user-friendly math parser for Lua, featuring support for variables, functions and customizable operators and operator precedence.

![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3%2C%205.4-blue?style=for-the-badge&logo=lua)
![GitHub stars](https://img.shields.io/github/stars/ByteXenon/MathParser.lua?style=for-the-badge)
![License](https://img.shields.io/github/license/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/ByteXenon/MathParser.lua?style=for-the-badge)
![Tests Passing](https://img.shields.io/badge/Tests-Passing-green?style=for-the-badge)
![100% Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-green?style=for-the-badge)

</div>

## Introduction

Welcome to MathParser.lua, a comprehensive math parser tailored specifically for Lua. With its structured design and well-commented code, this parser is accessible to both newcomers and seasoned developers alike.

MathParser.lua is capable of handling a wide array of mathematical problems, providing a reliable solution for your computational needs. But it doesn't stop there. It offers a high degree of customization, allowing you to extend its functionality by adding your own functions, variables, and operators. You even have the flexibility to alter the precedence of operations to suit your needs. For instance, you can configure the parser to prioritize addition over multiplication - a level of customization that truly sets MathParser.lua apart from other math parsers.

One of the defining features of MathParser.lua is its thorough test coverage. We've ensured that every line of code is put through rigorous testing, guaranteeing its reliability and robustness. Furthermore, it's compatible with various Lua versions, starting from Lua-5.1, including LuaJIT. It's even compatible with Luau, making it a viable choice for your Roblox projects.

## Table of Contents

- [MathParser.lua - A Robust Lua Math Parser](#mathparserlua---a-robust-lua-math-parser)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Usage](#usage)
    - [Getting Started](#getting-started)
    - [Advanced Usage](#advanced-usage)
  - [Roadmap](#roadmap)
  - [License](#license)

**Quick Links:** [API](./src/MathParser.lua) | [License](./LICENSE) | [Documentation](./docs/Documentation.md) | [Example](./example.lua)

## Features

1. **User-Friendly**: MathParser.lua boasts an intuitive API, making it a breeze to integrate into your projects. Its comprehensive documentation provides clear examples and explanations, while its error messages are designed to pinpoint the exact location of issues, reducing debugging time.
2. **Safe and Secure**: Safety is a priority with MathParser.lua. It avoids the use of the `load` function, which can execute any Lua code. Instead, it employs a custom parser to process input expressions, ensuring only valid mathematical operations are executed. If an input is invalid or potentially harmful, MathParser.lua throws an error, providing detailed information about the issue.
3. **Compact and Efficient**: MathParser.lua is a lean project with no external dependencies, making it easy to incorporate into your codebase. Its compact size doesn't compromise its functionality, offering a powerful tool that's easy to understand and modify.
4. **Highly Customizable**: MathParser.lua offers extensive customization options. You can add custom functions, variables, and operators, and even change the order in which operations are done. This flexibility allows you to tailor MathParser.lua to your specific needs, making it a versatile tool for a wide range of applications.

## Usage

MathParser.lua is a versatile tool that can handle everything from simple arithmetic to complex mathematical expressions. Whether you're integrating it into a large project or using it for quick calculations, here's a comprehensive guide to get you started.

### Getting Started

Using MathParser.lua is as easy as 1-2-3. Here's a quick example to get you started:
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

It was just a simple example. For more advanced usage, let's move on to the next section.

### Advanced Usage

MathParser.lua is not just a simple math parser, it's a powerful tool that can be customized to suit your needs. It supports the addition of custom functions, variables, and operators, allowing you to extend its functionality beyond basic math operations. Let's use all these features to demonstrate how you can use MathParser.lua in more advanced scenarios.

Here's an example code snippet that demonstrates the advanced usage of MathParser.lua:
```lua
local MathParser = require("MathParser")
local myParser = MathParser:new()

-- Add a variable and a function
myParser:addVariable("x", 5)
myParser:addFunction("double", function(a) return a * 2 end)

-- Solve expressions using the custom function and variable
print(myParser:solve("-double(x)")) -- Outputs: -10

-- Customize operator precedence levels and functions
local CUSTOM_OPERATOR_PRECEDENCE_LEVELS = {
  Unary = { ["-"] = 3 },
  Binary = { ["^"] = 2, ["+"] = 1, ["-"] = 1 },
  RightAssociativeBinaryOperators = { ["^"] = true }
}

local CUSTOM_OPERATOR_FUNCTIONS = {
  Unary = { ["-"] = function(a) return -a end },
  Binary = {
    ["^"] = function(a, b) return (a + b) % 2 end,
    ["+"] = function(a, b) return a - b end,
    ["-"] = function(a, b) return a + b end
  }
}

myParser:setOperatorPrecedenceLevels(CUSTOM_OPERATOR_PRECEDENCE_LEVELS)
myParser:setOperatorFunctions(CUSTOM_OPERATOR_FUNCTIONS)

-- Solve expressions using the custom operators
print(myParser:solve("5 - 3")) -- Outputs: 8
print(myParser:solve("5 + 3")) -- Outputs: 2
print(myParser:solve("5 ^ 3")) -- Outputs: 0
```

For more details, refer to the [documentation](docs/Documentation.md), the [API source](src/MathParser.lua), or the [full example usage file](./example.lua).

## Roadmap

MathParser.lua is just getting started. Here are some of the enhancements and features we're planning for future releases:

- [ ] Introduce support for internal functions that can modify the evaluator's state at runtime. This includes setting variables and jumping to different parts of the expression.
- [x] Package MathParser.lua into a single file for easy distribution and usage. We also plan to make it available on LuaRocks and the project's GitHub releases.
- [ ] Implement full support for Luau to cater to the Roblox developer community.
- [ ] Expand the mathematical function library to include advanced functions not available in the standard Lua math library, such as factorial, permutations, and combinations.
- [ ] Incorporate support for complex numbers to handle more sophisticated mathematical problems.
- [ ] Optimize MathParser.lua further to enhance speed and reduce memory usage.
- [ ] Develop optional support for parsing and solving equations and inequalities.
- [ ] Add optional support for solving differential and integral equations.

We welcome feature requests and suggestions for improvements. Feel free to open an issue or a pull request. Your feedback is highly appreciated!

## License

MathParser.lua is (re)licensed under the [MIT License](LICENSE).
