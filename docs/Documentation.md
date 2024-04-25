# MathParser.lua Documentation
- [MathParser.lua Documentation](#mathparserlua-documentation)
  - [Introduction](#introduction)
  - [Detailed Breakdown](#detailed-breakdown)
    - [Lexer](#lexer)
    - [Parser](#parser)
    - [Evaluator](#evaluator)

## Introduction

MathParser.lua is a tool that can understand and solve math problems given as text. It's built around three main parts: "Lexer", "Parser", and "Evaluator". Each part plays a key role in understanding and solving the math problems that are given to it.

## Detailed Breakdown

### Lexer

The Lexer is the first step. It takes a text input, which is a math problem, and breaks it down into a list of words and symbols. This list is called tokens. The Lexer is good at recognizing different things like numbers, variables, math symbols, and more. This process lets us understand the problem in smaller pieces, getting it ready for the next step.

### Parser

The Parser takes over from the Lexer. It takes the list of tokens and turns it into a tree structure, called an Abstract Syntax Tree (AST). The AST is a way of showing the math problem where each branch is a math operation, and the leaves are the numbers or variables. This tree structure lets us understand the problem in terms of its math relationships, which is important for solving it correctly.

Example of an AST:  
![Parsing Example](https://upload.wikimedia.org/wikipedia/commons/6/68/Parsing_Example.png)

### Evaluator

The Evaluator is the last step. It takes the AST from the Parser and solves it to give the answer. The Evaluator goes through the AST, doing the math operations as it goes along. The result of this is the final answer to the math problem.
