local Parser = require("parser")

local sample_markdown = [[
# Welcome to Lua Markdown

This is a **lightweight** parser written in *Lua*.

## Features
- Fast parsing
- Simple patterns
- [Check it out](https://lua.org)

### Example
Here is some bold text **Hello!** and some italics *World*.

- Item one
- Item two with **bold**
- Item three

Final paragraph after a list.
]]

print("--- Markdown Input ---")
print(sample_markdown)
print("\n--- HTML Output ---")
print(Parser.parse(sample_markdown))