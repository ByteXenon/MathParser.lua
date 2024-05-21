#!/bin/bash

version=$1

rockspec=$(cat <<EOF
package = "MathParser"
version = "$version"
source = {
  url = "https://github.com/ByteXenon/MathParser.lua/archive/v$version.tar.gz"
}
description = {
  summary = "A math parser for Lua.",
  detailed = "An elegant Math Parser written in Lua, featuring support for adding custom operators and functions.",
  homepage = "https://github.com/ByteXenon/MathParser.lua",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["MathParser"] = "MathParser.min.lua"
  }
}
EOF
)

echo "$rockspec" > "MathParser-$version.rockspec"