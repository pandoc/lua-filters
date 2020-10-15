--  DESCRIPTION
--
--    This Lua filter for Pandoc converts LaTeX math to MathJax generated
--    scalable vector graphics (SVG) in any of the available MathJax fonts.
--    This is useful when a CSS paged media engine cannot process complex JavaScript.
--    No Internet connection is required for SVG conversions, resulting in absolute privacy.


--  REQUIREMENTS, USAGE & PRIVACY
--
--    See: https://github.com/pandoc/lua-filters/tree/master/math2svg


--  LICENSE
--
--    Copyright (c) 2020 Serge Y. Stroobandt
--
--    MIT License
--
--    Permission is hereby granted, free of charge, to any person obtaining a copy
--    of this software and associated documentation files (the "Software"), to deal
--    in the Software without restriction, including without limitation the rights
--    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--    copies of the Software, and to permit persons to whom the Software is
--    furnished to do so, subject to the following conditions:
--
--    The above copyright notice and this permission notice shall be included in all
--    copies or substantial portions of the Software.
--
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--    SOFTWARE.


--  CONTACT
--
--    $ echo c2VyZ2VAc3Ryb29iYW5kdC5jb20K |base64 -d


--  The full path to the tex2svg binary of the mathjax-node-cli package.
local tex2svg = '/usr/local/bin/tex2svg'

--  By default, DisplayMath is converted to SVG, whereas InlineMath is not.
local display2svg = true
local inline2svg  = false
--  The fallback is MathML when pandoc is executed with the --mathml argument.

--  Speech text inclusion
local speech = false

--  Automatic line breaking
local linebreaks = true

--  The default MathJax font
local font = 'TeX'
--  Supported MathJax fonts are: https://docs.mathjax.org/en/latest/output/fonts.html

--  ex size in pixels
local ex = 6

--  Container width in ex
local width = 100

--  String of extensions to be loaded at run time
local extensions = ''
--  Available extensions are listed in:
--  /usr/local/lib/node_modules/mathjax-node-cli/node_modules/mathjax/unpacked/extensions/


function Meta(meta)

  display2svg = meta.math2svg_display2svg or display2svg
  inline2svg  = meta.math2svg_inline2svg or inline2svg
  tex2svg     = tostring(meta.math2svg_tex2svg or tex2svg)
  speech      = tostring(meta.math2svg_speech or speech)
  linebreaks  = tostring(meta.math2svg_linebreaks or linebreaks)
  font        = tostring(meta.math2svg_font or font)
  ex          = tostring(meta.math2svg_ex or ex)
  width       = tostring(meta.math2svg_width or width)
  extensions  = tostring(meta.math2svg_extensions or extensions)

end


function Math(elem)

  local svg  = nil
  local tags = nil
  local argumentlist = {'--speech', speech, '--linebreaks', linebreaks, '--font', font, '--ex', ex, '--width', width, '--extensions', extensions, elem.text}

--  The available options for tex2svg are:
    --help        Show help                                                   [boolean]
    --version     Show version number                                         [boolean]
    --inline      process as in-line TeX                                      [boolean]
    --speech      include speech text                         [boolean] [default: true]
    --linebreaks  perform automatic line-breaking                             [boolean]
    --font        web font to use                                      [default: "TeX"]
    --ex          ex-size in pixels                                        [default: 6]
    --width       width of container in ex                               [default: 100]
    --extensions  extra MathJax extensions e.g. 'Safe,TeX/noUndefined'    [default: ""]

  if elem.mathtype == 'DisplayMath' and display2svg then
    svg  = pandoc.pipe(tex2svg, argumentlist, '')
    tags = {'<div class="math display">', '</div>'}

  elseif elem.mathtype == 'InlineMath' and inline2svg then
    table.insert(argumentlist, 1, '--inline')
    svg  = pandoc.pipe(tex2svg, argumentlist, '')
    tags = {'<span class="math inline">', '</span>'}

  end

  if svg then

    if FORMAT:match '^html.?' then
      svg = tags[1] .. svg .. tags[2]
      return pandoc.RawInline(FORMAT, svg)
    else
      local filename = pandoc.sha1(svg) .. '.svg'
      pandoc.mediabag.insert(filename, 'image/svg+xml', svg)
      return pandoc.Image('', filename)
    end

  else
    return elem

  end

end


-- Redefining the execution order.
return {
  {Meta = Meta},
  {Math = Math}
}
