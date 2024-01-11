#!/bin/bash
lua tests/init.lua
if [ $? -ne 0 ]; then
  exit 1
fi