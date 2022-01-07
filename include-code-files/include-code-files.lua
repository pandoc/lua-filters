--- include-code-files.lua – filter to include code from source files
---
--- Copyright: © 2020 Bruno BEAUFILS
--- License:   MIT – see LICENSE file for details

--- Dedent a line
local function dedent (line, n)
  return line:sub(1,n):gsub(" ","") .. line:sub(n+1)
end

--- Filter function for code blocks
local function transclude (cb)
  if cb.attributes.include then
    local wget_path = os.getenv("WGET") or "wget"
    local tmpfile = os.tmpname()
    local fn=cb.attributes.include
    if string.sub(fn,1,1) == "~" then
      fn = os.getenv("HOME")..string.sub(fn,2)
    end
    if (string.sub(fn,1,7) == "http://") or (string.sub(fn,1,8) == "https://") then
      local command=wget_path and wget_path .. ' --no-check-certificate ' .. fn .. ' -O ' .. tmpfile
      os.execute(command)
      fn = tmpfile
    end
    local content = ""
    local fh = io.open(fn)
    if not fh then
      io.stderr:write("Cannot open file " .. fn .. " | Skipping includes\n")
    else
      local number = 1
      local start = 1

      -- change hyphenated attributes to PascalCase
      for i,pascal in pairs({"startLine", "endLine"})
      do
         local hyphen = pascal:gsub("%u", "-%0"):lower()
         if cb.attributes[hyphen] then
            cb.attributes[pascal] = cb.attributes[hyphen]
            cb.attributes[hyphen] = nil
         end
      end

      if cb.attributes.startLine then
        cb.attributes.startFrom = cb.attributes.startLine
        start = tonumber(cb.attributes.startLine)
      end
      for line in fh:lines ("L")
      do
        if cb.attributes.dedent then
          line = dedent(line, cb.attributes.dedent)
        end
        if number >= start then
          if not cb.attributes.endLine or number <= tonumber(cb.attributes.endLine) then
            content = content .. line
          end
        end
        number = number + 1
      end 
      fh:close()
    end     
    -- remove key-value pair for used keys
    cb.attributes.include = nil
    cb.attributes.startLine = nil
    cb.attributes.endLine = nil
    cb.attributes.dedent = nil
    -- return final code block
    return pandoc.CodeBlock(content, cb.attr)
  end
end

return {
  { CodeBlock = transclude }
}
