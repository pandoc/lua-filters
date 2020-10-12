--  DESCRIPTION
--
--    This Lua filter for Pandoc converts LaTeX math to MathJax generated
--    scalable vector graphics (SVG) in any of the available MathJax fonts.
--
--    This is useful when a CSS paged media engine cannot process complex JavaScript
--    as required by MathJax. See: https://www.print-css.rocks for information about
--    CSS paged media, a W3C standard.
--
--    No Internet connection is required for SVG conversions, resulting in absolute
--    privacy.


--  REQUIREMENTS
--
--    First, use the package manager of your operating system to install
--    pandoc, nodejs and npm. `brew` and `choco` are recommended package mangers for
--    respectively macOS and Windows. See: <https://pandoc.org/installing.html>
--
--      $ sudo apt install pandoc nodejs npm
--      $ sudo dnf install pandoc nodejs npm
--      $ sudo yum install pandoc nodejs npm
--      $ brew install pandoc nodejs npm
--      > choco install pandoc nodejs npm
--
--    Then, install mathjax-node-cli using npm.
--    Leave out the sudo on Windows.
--
--      $ sudo npm install --global mathjax-node-cli
--      > npm install --global mathjax-node-cli


--  USAGE
--
--    To be used as a Pandoc Lua filter.
--    MathML should be set as a fallback.
--
--      pandoc --mathml --filter='math2svg.lua'
--
--    See also: https://pandoc.org/lua-filters.html


--  PRIVACY
--
--    No Internet connection is established when creating MathJax SVG code using
--    the tex2svg command of mathjax-node-cli.
--    Hence, formulas in SVG can be created offline and will remain private.
--
--    For code auditing, see also:
--      - https://github.com/mathjax/MathJax-node
--      - https://github.com/pkra/mathjax-node-sre
--      - https://github.com/mathjax/mathjax-node-cli


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


--  Enter here the full path to the tex2svg binary of mathjax-node-cli.
--  The full path can be found with the following command:
--    $ which tex2svg
local tex2svg = '/usr/local/lib/node_modules/mathjax-node-cli/bin/tex2svg'


--  Supported MathJax fonts are: https://docs.mathjax.org/en/latest/output/fonts.html
local font = 'Gyre-Pagella'


--  Indicate with true or false whether DisplayMath and InlineMath should be converted to SVG.
local display2svg = true
local inline2svg  = false
--  The fallback is MathML if pandoc is executed with the --mathml argument.
--  MathML output gets generated much faster than SVG output.
--  Moreover, MathML is better suited to InlineMath as line heights are kept small.


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


local function convert(elem)
  return pandoc.pipe(tex2svg, {'--speech=false', '--font', font, elem.text}, '')
end


function Math(elem)

  local svg  = nil
  local tags = nil

  if elem.mathtype == 'DisplayMath' and display2svg then
    svg  = convert(elem)
    tags = {'<div class="math display">', '</div>'}

  elseif elem.mathtype == 'InlineMath' and inline2svg then
    svg  = convert(elem)
    tags = {'<span class="math inline">', '</span>'}

  end

  if svg then

    if FORMAT:match '^html.?' then
      svg =  tags[1] .. svg .. tags[2]
      return pandoc.RawInline(FORMAT, svg)

    else
      local filename = pandoc.sha1(svg) .. '.svg'
      pandoc.mediabag.insert(filename, 'image/svg+xml', svg)
      return pandoc.Image('', filename)

    end

  end

end
