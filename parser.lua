local Parser = {}

local inline_rules = {
  -- Bold
  { pattern = "%%**(.-)%%**", replacement = "<strong>%1</strong>" },
  -- Italic
  { pattern = "%%*(.-)%%*", replacement = "<em>%1</em>" },
  -- Links
  { pattern = "%%[(.-)%%]%((.-)%%)", replacement = '<a href="%2">%1</a>' },
}

function Parser.parse(text)
  local lines = {}
  for line in text:gmatch("[^\n]*\n?") do
    table.insert(lines, line:gsub("\n$", ""))
  end

  local output = {}
  local in_list = false

  for _, line in ipairs(lines) do
    local processed = line
    local is_header = false
    local is_list_item = false

    -- Header detection
    for i = 1, 3 do
      local header_pat = "^#" .. string.rep("#", i-1) .. "%%s+(.+)$"
      if processed:match(header_pat) then
        processed = processed:gsub(header_pat, "<h" .. i .. ">%1</h" .. i .. ">")
        is_header = true
        break
      end
    end

    -- List item detection (starts with - or *)
    if not is_header and processed:match("^[%-%*]%s+(.+)$") then
      processed = processed:gsub("^[%-%*]%s+(.+)$", "%1")
      is_list_item = true
    end

    -- Apply inline rules
    for _, rule in ipairs(inline_rules) do
      processed = processed:gsub(rule.pattern, rule.replacement)
    end

    -- List block management
    if is_list_item then
      if not in_list then
        table.insert(output, "<ul>")
        in_list = true
      end
      table.insert(output, "  <li>" .. processed .. "</li>")
    else
      if in_list then
        table.insert(output, "</ul>")
        in_list = false
      end

      if processed == "" then
        -- Ignore empty lines inside or between blocks
      elseif is_header then
        table.insert(output, processed)
      else
        table.insert(output, "<p>" .. processed .. "</p>")
      end
    end
  end

  if in_list then
    table.insert(output, "</ul>")
  end

  return table.concat(output, "\n")
end

return Parser