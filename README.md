# Lua Markdown Parser

A simple, pattern-based Markdown to HTML converter implemented in Lua.

## Usage

1. Include `parser.lua` in your project.
2. Call `Parser.parse(text)` with your markdown string.

```lua
local Parser = require("parser")
local html = Parser.parse("# Hello World")
print(html) -- <h1>Hello World</h1>
```