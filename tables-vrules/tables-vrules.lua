 --[[
tables-vrules - adds vertical rules to tables for latex output

Copyright:  © 2021 Christophe Agathon <christophe.agathon@gmail.com>

License:    MIT – see LICENSE file for details

Credits:    marijnschraagen for the original Latex hack

Output:     latex, pdf.

Usage:      See README.md for details

--]]
local List = require 'pandoc.List'


function Table(table)
  local returned_list
  local latex_code = ''
  local coldef =''
  local envdef =''
  local new_coldef =''

  if FORMAT:match 'latex' then

    latex_code = pandoc.write ( pandoc.Pandoc({table}),'latex' )
    envdef, begdef, coldef, enddef =
          latex_code:match("((\\begin{longtable}%[[^%]]*%]{@{})(.*)(@{}}))")

    if not coldef then return nil end

    if coldef:match('^[lrc]+$') then
      -- old style
      new_coldef = coldef:gsub('(.)','|%1') .. '|'
    else
      -- asuming new style
      new_coldef = coldef:gsub('(>)','|%1') .. '|'
    end
    returned_list = List:new{pandoc.RawBlock('tex',
                               begdef .. new_coldef .. enddef ..
                               latex_code:sub(envdef:len() + 1))}
  end
  return returned_list
end

function Meta(meta)
  -- We have to add this since Pandoc doesn't do it when a filter is
  -- processing tables (is it a bug or a feature ???)

  includes = [[%begin tables-vrules.lua
  \usepackage{longtable,booktabs,array}
	\usepackage{calc} % for calculating minipage widths
	% Correct order of tables after \paragraph or \subparagraph
	\usepackage{etoolbox}
	\makeatletter
	\patchcmd\longtable{\par}{\if@noskipsec\mbox{}\fi\par}{}{}
	\makeatother
	% Allow footnotes in longtable head/foot
	\IfFileExists{footnotehyper.sty}{\usepackage{footnotehyper}}{\usepackage{footnote}}
	\makesavenoteenv{longtable}
  \setlength{\aboverulesep}{0pt}
  \setlength{\belowrulesep}{0pt}
  \renewcommand{\arraystretch}{1.3}
%end tables-vrules.lua]]

  if meta['header-includes'] then
    table.insert(meta['header-includes'], pandoc.RawBlock('tex', includes))
  else
    meta['header-includes'] = List:new{pandoc.RawBlock('tex', includes)}
  end

  return meta
end
