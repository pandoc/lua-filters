--[[

commonmark-code-blocks -- produces code blocks with language CSS class format
suggested by the CommonMark specification ("language-$lang").

MIT License

Copyright (c) 2021 Daniil Baturin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--[[

The CommonMark spec suggests that 
"```somelang" should produce <code class="language-somelang">

That's what most CommonMark implementations do.

Pandoc, however, outputs <code class="somelang">

That can be a problem for syntax highlighters that expect
"language-*" classes and use them to determine the language.
 
This filter takes over the code block rendering process
to produce CommonMark-style output.

]]

function CodeBlock(block)
  if FORMAT:match 'html' then
    local lang_attr = ""
    if (#block.classes > 0) then
      lang_attr = string.format("class=\"language-%s\"", block.classes[1])
    else
      -- Ignore code blocks where language is not specified
    end

    local code = block.text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")

    local html = string.format('<pre><code %s>%s</code></pre>', lang_attr, code)
    return pandoc.RawBlock('html', html)
  end
end

