--    DESCRIPTION
--
--      This Lua filter for Pandoc converts LaTeX DisplayMath to MathJax generated
--      scalable vector graphics (SVG) in any of the available MathJax fonts.
--
--      This is useful when a CSS paged media engine cannot process complex JavaScript
--      as required by MathJax.
--
--      See: https://www.print-css.rocks for information about CSS paged media, a W3C
--      standard.
--
--      This filter also defines the missing LaTeX commands \j and \e{} for displaying
--      the imaginary unit j and the exponential function with Euler constant e.


--    REQUIRES
--
--      $ sudo apt install pandoc pandoc-citeproc libghc-pandoc-prof nodejs npm
--      $ sudo npm install --global mathjax-node-cli


--    USAGE
--
--      To be used as a Pandoc Lua filter.
--      pandoc --mathml --filter='displaymath2svg.lua'
--
--      See also: https://pandoc.org/lua-filters.html


--    PRIVACY
--
--      No Internet connection is established when creating MathJax SVG code using
--      the tex2svg command of mathjax-node-cli.
--      Hence, formulas in SVG can be created offline and remain private.
--
--      For code auditing, see also:
--          - https://github.com/mathjax/MathJax-node
--          - https://github.com/pkra/mathjax-node-sre
--          - https://github.com/mathjax/mathjax-node-cli


--    COPYRIGHT
--
--      Copyright 2020 Serge Y. Stroobandt
--
--      This program is free software: you can redistribute it and/or modify
--      it under the terms of the GNU General Public License as published by
--      the Free Software Foundation, either version 3 of the License, or
--      (at your option) any later version.
--
--      This program is distributed in the hope that it will be useful,
--      but WITHOUT ANY WARRANTY; without even the implied warranty of
--      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--      GNU General Public License for more details.
--
--      You should have received a copy of the GNU General Public License
--      along with this program.  If not, see <https://www.gnu.org/licenses/>.


--    CONTACT
--
--      $ echo c2VyZ2VAc3Ryb29iYW5kdC5jb20K |base64 -d


--  Supported MathJax fonts are: https://docs.mathjax.org/en/latest/output/fonts.html
local font = 'Gyre-Pagella'


--  Some missing LaTeX math commands are defined here:
local newcommands = '\\newcommand{\\j}{{\\text{j}}}\\newcommand{\\e}[1]{\\,{\\text{e}}^{#1}}'


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


function Math(elem)
    if elem.mathtype == 'DisplayMath' then
        local svg = pandoc.pipe('/usr/local/lib/node_modules/mathjax-node-cli/bin/tex2svg', {'--speech=false', '--font', font, newcommands .. elem.text}, '')
        if FORMAT:match '^html.?' then
            svg = '<div class="math display">' .. svg .. '</div>'
        end
        return pandoc.RawInline(FORMAT, svg)
    end
end
