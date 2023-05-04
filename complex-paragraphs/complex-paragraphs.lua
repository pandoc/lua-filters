--[[
complex-paragraphs – compose complex paragraphs

Copyright © 2021 Bastien Dumont

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

local is_after_first_block
local RAW_ATTRIBUTE

if FORMAT == 'native' then
  RAW_ATTRIBUTE = pandoc.system.environment().TESTED_FORMAT
elseif FORMAT == 'docx' then
  RAW_ATTRIBUTE = 'openxml'
elseif FORMAT == 'context' or FORMAT == 'latex' then
  RAW_ATTRIBUTE = FORMAT
else
  error(FORMAT ..
        ' output not supported by complex-paragraphs.lua\n')
end

local function make_noindent_code()
  if RAW_ATTRIBUTE == 'context' then
    return '\\noindentation{}'
  elseif RAW_ATTRIBUTE == 'openxml' then
    return '<w:pPr>' ..
      '<w:pStyle w:val="BodyText"/>' ..
      '<w:ind w:hanging="0"/>' ..
      '<w:rPr></w:rPr></w:pPr>'
  elseif RAW_ATTRIBUTE == 'latex' then
    return '\\noindent{}'
  end
end

local noindent_rawinline =
  pandoc.RawInline(RAW_ATTRIBUTE, make_noindent_code())

local function turn_to_nonindented_textblock(para)
  para.c:insert(1, noindent_rawinline)
end

local function unindent_paragraphs_after_first_block_in_complex_para(blocks)
  for i = 1, #blocks do
    block = blocks[i]
    if block.t == 'Para' and is_after_first_block then
      turn_to_nonindented_textblock(block)
    elseif block.t == 'Div' then
      unindent_paragraphs_after_first_block_in_complex_para(block.content)
    end
    is_after_first_block = true
  end
end

local function turn_to_complex_paragraph(div)
  unindent_paragraphs_after_first_block_in_complex_para(div.content)
end

function Div(div)
  if div.classes[1] == 'complex-paragraph' then
    is_after_first_block = false
    turn_to_complex_paragraph(div)
    return div
  end
end
