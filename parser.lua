local Parser = {}

local rules = {
  -- Headers
  { pattern = "^#%s+(.+)$", replacement = "<h1>%1</h1>" },
  { pattern = "^##%s+(.+)$", replacement = "<h2>%1</h2>" },
  { pattern = "^###%s+(.+)$", replacement = "<h3>%1</h3>" },
  -- Bold
  { pattern = "%**(.-)%**", replacement = "<strong>%1</strong>" },
  -- Italic
  { pattern = "%*(.-)%*", replacement = "<em>%1</em>" },
  -- Links
  { pattern = "%[(.-)%]%((.-)%)", replacement = '<a href="%2">%1</a>' },
}

function Parser.parse(text)
  local lines = {}
  for line in text:gmatch("[^\n]*\n?") do
    table.insert(lines, line:gsub("\n$", ""))
  end

  local output = {}
  for _, line in ipairs(lines) do
    local processed = line
    local matched_header = false

    -- Try header rules first
    for i = 1, 3 do
      local header_pat = "^#" .. string.rep("#", i-1) .. "%s+(.+)$"
      local header_rep = "<h" .. i .. ">%1</h" .. i .. ">"
      if processed:match(header_pat) then
        processed = processed:gsub(header_pat, header_rep)
        matched_header = true
        break
      end
    end

    -- Apply inline rules if not a header or as general inline processing
    for _, rule in ipairs(rules) do
      if not (rule.pattern:match("^#") and matched_header) then
        processed = processed:gsub(rule.pattern, rule.replacement)
      end
    end

    if processed == "" then
      table.insert(output, "<br />")
    elseif not matched_header and not processed:match("^<h") then
      table.insert(output, "<p>" .. processed .. "</p>")
    else
      table.insert(output, processed)
    end
  end

  return table.concat(output, "\n")
end

return Parser