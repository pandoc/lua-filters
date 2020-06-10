if FORMAT ~= 'latex' then
  return {}
end

function split_hyphen(inputstr)
  local sep = '-'
  local t = {}
  for str in string.gmatch(inputstr, '([^'..sep..']+)') do
    table.insert(t, str)
  end
  return t
end

function Str(elem)
  local parts = split_hyphen(elem.c)
  -- if not more than one part, string contains no hyphen, return unchanged.
  if #parts <= 1 then
    return nil
  end
  -- otherwise, splice raw latex "= between parts
  local o = {}
  for index, part in ipairs(parts) do
    table.insert(o, pandoc.Str(part))
    if index < #parts then
      table.insert(o, pandoc.RawInline('latex', '"='))
    end
  end
  return o
end
