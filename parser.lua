local Parser = {}

local inline_rules = {
  -- Inline Code
  { pattern = "%%`(.-)%%`", replacement = "<code>%1</code>" },
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
  local list_type = nil -- "ul" or "ol"
  local in_blockquote = false

  for _, line in ipairs(lines) do
    local processed = line
    local is_header = false
    local is_list_item = false
    local current_list_type = nil
    local is_blockquote_item = false

    -- Blockquote detection
    if processed:match("^%s*>%s*(.+)$") then
      processed = processed:gsub("^%s*>%s*(.+)$", "%1")
      is_blockquote_item = true
    end

    -- Header detection
    for i = 1, 3 do
      local header_pat = "^#" .. string.rep("#", i-1) .. "%%s+(.+)$"
      if processed:match(header_pat) then
        processed = processed:gsub(header_pat, "<h" .. i .. ">%1</h" .. i .. ">")
        is_header = true
        break
      end
    end

    -- List item detection
    if not is_header then
      if processed:match("^[%-%*]%s+(.+)$") then
        processed = processed:gsub("^[%-%*]%s+(.+)$", "%1")
        is_list_item = true
        current_list_type = "ul"
      elseif processed:match("^%d+%.%s+(.+)$") then
        processed = processed:gsub("^%d+%.%s+(.+)$", "%1")
        is_list_item = true
        current_list_type = "ol"
      end
    end

    -- Apply inline rules
    for _, rule in ipairs(inline_rules) do
      processed = processed:gsub(rule.pattern, rule.replacement)
    end

    -- List block management
    if is_list_item then
      if not in_list or list_type ~= current_list_type then
        if in_list then
          table.insert(output, "</" .. list_type .. ">")
        end
        table.insert(output, "<" .. current_list_type .. ">")
        in_list = true
        list_type = current_list_type
      end
      processed = "  <li>" .. processed .. "</li>"
    else
      if in_list then
        table.insert(output, "</" .. list_type .. ">")
        in_list = false
        list_type = nil
      end

      if processed == "" then
        -- Ignore empty lines
        processed = nil
      elseif is_header then
        -- processed is already wrapped in h tags
      else
        processed = "<p>" .. processed .. "</p>"
      end
    end

    -- Blockquote block management
    if is_blockquote_item then
      if not in_blockquote then
        table.insert(output, "<blockquote>")
        in_blockquote = true
      end
      if processed then
        table.insert(output, processed)
      end
    else
      if in_blockquote then
        table.insert(output, "</blockquote>")
        in_blockquote = false
      end
      if processed then
        table.insert(output, processed)
      end
    end
  end

  if in_list then
    table.insert(output, "</" .. list_type .. ">")
  end
  if in_blockquote then
    table.insert(output, "</blockquote>")
  end

  return table.concat(output, "\n")
end

return Parser