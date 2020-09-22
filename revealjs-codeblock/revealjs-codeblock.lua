--[[
revealjs-codeblock - enable reveal.js code presentation features

Copyright © 2020 Tim Sokollek

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]
local function is_numberlines_class(class)
  return class == 'numberLines' or class == 'number-lines'
end

local function is_pre_tag_attribute(attribute)
  return attribute == 'data-id'
end

local function is_data_line_number_in_attributes(attributes)
  for _, attribute in ipairs(attributes) do
    if attribute[1] == 'data-line-numbers' then return true end
  end
  return false
end

function CodeBlock(block)
  if FORMAT == 'revealjs' then
    local css_classes = {}
    local pre_tag_attributes = {}
    local code_tag_attributes = {}

    for _, class in ipairs(block.classes) do
      if is_numberlines_class(class) then
        if not is_data_line_number_in_attributes(block.attributes) then
          table.insert(block.attributes, {'data-line-numbers', ''})
        end
      else
        table.insert(css_classes, class)
      end
    end
    if block.identifier ~= '' then
      table.insert(pre_tag_attributes,
                    string.format('id="%s"', block.identifier))
    end
    if next(css_classes) then
      class_attribute = string.format('class="%s"',
                                      table.concat(css_classes, ' '))
      table.insert(code_tag_attributes, class_attribute)
    end
    for _, attribute in ipairs(block.attributes) do
      attribute_string = string.format('%s="%s"', attribute[1],
                                        attribute[2])
      if is_pre_tag_attribute(attribute[1]) then
        table.insert(pre_tag_attributes, attribute_string)
      else
        table.insert(code_tag_attributes, attribute_string)
      end
    end
    local html = string.format('<pre %s><code %s>%s</code></pre>',
                                table.concat(pre_tag_attributes, ' '),
                                table.concat(code_tag_attributes, ' '),
                                block.text:gsub("<", "&lt;"):gsub(">", "&gt;"))
    return pandoc.RawBlock('html', html)
  end
end
