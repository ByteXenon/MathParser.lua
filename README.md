<div align="center">

<img src="https://github.com/ByteXenon/MathParser.lua/assets/125568681/7c85601d-1218-414b-9545-f5e57d48c061" alt="MathParser.lua logo" width="200" height="200">

# MathParser.lua - A Customizable and Fast Lua Math Parser

A powerful and customizable Lua math parser that can solve both simple arithmetic problems and complex mathematical expressions. It supports adding variables, functions, custom operators, and operator precedence levels. It's designed to be safe, fast, and easy to use.

![Lua](https://img.shields.io/badge/Lua-5.1%2C%205.2%2C%205.3%2C%205.4-blue?style=for-the-badge&logo=lua)
![GitHub stars](https://img.shields.io/github/stars/ByteXenon/MathParser.lua?style=for-the-badge)
![License](https://img.shields.io/github/license/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/ByteXenon/MathParser.lua?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues/ByteXenon/MathParser.lua?style=for-the-badge)
![Tests Passing](https://img.shields.io/badge/Tests-Passing-green?style=for-the-badge)
![100% Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-green?style=for-the-badge)

</div>

## Introduction

MathParser.lua can solve many different types of math problems. It's a tool that can be used for solving [simple arithmetic problems](#getting-started), as well as [more complex mathematical expressions](#advanced-usage). It supports adding variables, functions, custom operators, and operator precedence levels (wiki: [Order of Operations](https://en.wikipedia.org/wiki/Order_of_operations)). It's also designed to be safe, so you can use it without worrying about security issues.

For a deeper understanding of its usage and functionality, refer to the [documentation](docs/Documentation.md). It provides detailed explanations on how to use MathParser.lua and how it works.

## Table of Contents

- [MathParser.lua - A Customizable and Fast Lua Math Parser](#mathparserlua---a-customizable-and-fast-lua-math-parser)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Usage](#usage)
    - [Getting Started](#getting-started)
    - [Advanced Usage](#advanced-usage)
  - [Roadmap](#roadmap)
  - [Contact](#contact)
  - [License](#license)

**Quick Links:** [API](./src/MathParser.lua) | [License](./LICENSE) | [Documentation](./docs/Documentation.md) | [Example](./example.lua)

## Features

1. **Easy to Use**: MathParser.lua is simple to use. It has a clear API and helpful documentation. If there's a problem, it gives you clear error messages to help you fix it quickly.
2. **Safe**: MathParser.lua is designed to be safe. Unlike *other* math parsers written in Lua, it doesn't use `loadstring` or `load` to evaluate expressions. Instead, it uses a custom parser and evaluator that were built from scratch. This makes it safe to use in any environment.
3. **Small and Fast**: MathParser.lua is a small project that doesn't need any other dependency to work.
4. **Customizable**: You can change MathParser.lua to do exactly what you want. You can add your own functions, variables, and operators. You can even change the order of operations. This makes it a useful tool for many different projects.

## Usage

MathParser.lua is a tool that can handle everything from simple arithmetic to complex mathematical expressions. Whether you're integrating it into a large project or using it for quick calculations, here's a comprehensive guide to get you started.

### Getting Started

Using MathParser.lua is very easy. Here's a simple example to demonstrate how you can use it to solve basic math problems:
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
- [x] Implement full support for Luau to cater to the Roblox developer community.
- [ ] Expand the mathematical function library to include advanced functions not available in the standard Lua math library, such as factorial, permutations, and combinations.
- [ ] Incorporate support for complex numbers to handle more sophisticated mathematical problems.
- [ ] Optimize MathParser.lua further to enhance speed and reduce memory usage.
- [ ] Develop optional support for parsing and solving equations and inequalities.
- [ ] Add optional support for solving differential and integral equations.

We welcome feature requests and suggestions for improvements. Feel free to open an issue or a pull request. Your feedback is highly appreciated!

## Contact

Do you have any questions, suggestions, or feedback? Feel free to open an issue on this GitHub repository. Alternatively, you can email the project maintainer, ByteXenon at `ddavi142(at)asu(dot)edu`

## License

MathParser.lua is (re)licensed under the [MIT License](LICENSE).
