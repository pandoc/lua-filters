--[[
pandoc-linguex: make interlinear glossing with pandoc

Copyright © 2021 Michael Cysouw <cysouw@mac.com>

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

PANDOC_VERSION:must_be_at_least '2.10'

---------------------
-- 'global' variables
---------------------

local counter = 0 -- actual numbering of examples
local chapter = 1 -- numbering of chapters (for unknown reasons this starts at 1, not 0)
local counterInChapter = 0 -- counter reset for each chapter
local indexEx = {} -- global lookup for example IDs
local orderInText = 0 -- order of references for resolving "Next"-style references
local indexRef = {} -- key/value: order in text = refID/exID
local rev_indexRef = {} -- "reversed" indexRef, i.e. key/value: refID/exID = order-number in text

------------------------------------
-- User Settings with default values
------------------------------------

local formatGloss = false -- format interlinear examples
local xrefSuffixSep = " " -- &nbsp; separator to be inserted after number in example references
local restartAtChapter = false -- restart numbering at highest header without adding local chapternumbers
local addChapterNumber = false -- add chapternumbers to counting and restart at highest header
local latexPackage = "linguex"
local topDivision = "section"

function getUserSettings (meta)
  if meta.formatGloss ~= nil then
    formatGloss = meta.formatGloss
  end
  if meta.xrefSuffixSep ~= nil then
    xrefSuffixSep = pandoc.utils.stringify(meta.xrefSuffixSep)
  end
  if meta.restartAtChapter ~= nil then
    restartAtChapter = meta.restartAtChapter
  end
  if meta.addChapterNumber ~= nil then
    addChapterNumber = meta.addChapterNumber
  end
  if meta.latexPackage ~= nil then
    latexPackage = pandoc.utils.stringify(meta.latexPackage)
  end
  if meta["top-level-division"] ~= nil then
    topDivision = pandoc.utils.stringify(meta["top-level-division"])
  end
end

------------------------------------------
-- add latex dependencies: langsci-gb4e is not on CTAN!
-- restarting of counters is not working right for gb4e
------------------------------------------

function addFormatting (meta)
  local tmp = meta['header-includes'] or pandoc.MetaList{meta['header-includes']}
  
  if FORMAT:match "html" then
    -- add specific CSS for layout of examples
    -- building on classes set in this filter
    -- local f = io.open("pandoc-ling.css")
    -- local css = f:read("*a")
    -- f:close()
    local css = [[ 
      <style>
      .linguistic-example { 
        margin: 0; 
      }
      .linguistic-example caption { 
        margin-bottom: 0; 
      }
      .linguistic-example tbody { 
        border-top: none; 
        border-bottom: none; 
        vertical-align: top; 
      }
      .linguistic-example td { 
        padding-left: 2px;
        padding-right: 4px; 
      }
      .linguistic-judgement { 
        padding-right: 0; 
      }
      </style>
      ]]
    tmp[#tmp+1] = pandoc.MetaBlocks(pandoc.RawBlock("html", css))
    
    meta['header-includes'] = tmp
  end
  
  if FORMAT:match "latex" then
    
    local function add (s)
      tmp[#tmp+1] = pandoc.MetaBlocks(pandoc.RawBlock("tex", s))
    end
  
    if latexPackage == "linguex" then
      add("\\usepackage{linguex}")
      -- no brackets
      add("\\renewcommand{\\theExLBr}{}")
      add("\\renewcommand{\\theExRBr}{}")
      --add("\\renewcommand{\\firstrefdash}{}")
      add("\\usepackage{chngcntr}")
      if addChapterNumber then
        add("\\counterwithin{ExNo}{"..topDivision.."}")
        add("\\renewcommand{\\Exarabic}{\\the"..topDivision..".\\arabic}")
      elseif restartAtChapter then
        add("\\counterwithin*{ExNo}{"..topDivision.."}")
      end

    elseif latexPackage:match "gb4e" then
      add("\\usepackage{"..latexPackage.."}")
      -- nnext package does not work with added top level number
      add("\\usepackage[noparens]{nnext}")
      add("\\usepackage{chngcntr}")
      if addChapterNumber then
        add("\\counterwithin{xnumi}{"..topDivision.."}")
      elseif restartAtChapter then
        add("\\counterwithin*{xnumi}{"..topDivision.."}")
      end

    elseif latexPackage == "expex" then
      add("\\usepackage{expex}")
      add("\\lingset{belowglpreambleskip=-1.5ex, aboveglftskip=-1.5ex, exskip=0ex, interpartskip=-0.5ex, belowpreambleskip=-1ex}")
      if addChapterNumber then
        add("\\lingset{exnotype=chapter.arabic}")
      end
      if restartAtChapter then
        --add("\\usepackage{epltxchapno}")
        add("\\usepackage{etoolbox}")
        add("\\pretocmd{\\"..topDivision.."}{\\excnt=1}{}{}")
      end

    end
    meta['header-includes'] = tmp
  end
  return meta
end

------------------------------------------
-- add invisible numbering to section
------------------------------------------

function addSectionNumbering (doc)
  local sections = pandoc.utils.make_sections(true, nil, doc.blocks)
  return pandoc.Pandoc(sections, doc.meta)
end

---------------------------
-- help function for format
---------------------------

function splitPara (p)
   -- remove quotes, they interfere with the layout
  if p[1].tag == "Quoted" then
    p = p[1].content
  end
  -- split paragraph in subtables at Space 
  -- to insert paragraph into pandoc.Table
  -- Is there a better way to do this in Pandoc-Lua?
	local start = 1
	local result = {}
	for i=1,#p do
		if p[i].tag == "Space" then
			local chunk = table.move(p, start, i-1, 1, {})
			table.insert(result, {pandoc.Plain(chunk)} )
			start = i + 1
		end
	end
	if start <= #p then
		local chunk = table.move(p, start, #p, 1, {})
		table.insert(result, {pandoc.Plain(chunk)} )
	end
	return result
end

function turnIntoTable (rowContent, nCols, extraCols)
  -- turn examples into Tables for alignment
  -- use simpleTable for construction
  local caption = {}
  local headers = {}
  local aligns = {}
    for i=1,nCols do aligns[i] = "AlignLeft" end
    aligns[extraCols + 1] = "AlignRight" -- Column for grammaticality judgements
  local widths = {}
    for i=1,nCols do widths[i] = 0 end
  local rows = rowContent

  local result = pandoc.SimpleTable(
      caption,
      aligns,
      widths,
      headers,
      rows
  )
  -- turn into fancy new tables
  result = pandoc.utils.from_simple_table(result)

  -- set class of table to "example" for styling via CSS
  result.attr = {class = "linguistic-example"}
  -- set class of judgment columns to "judgment" for styling via CSS
  for i=1,#result.bodies[1].body do
    result.bodies[1].body[i][2][extraCols+1].attr = pandoc.Attr(nil, {"linguistic-judgement"})
  end

  return result
end

function splitForSmallCaps (s)
	-- turn uppercase in gloss into small caps
	local split = {}
	for lower,upper in string.gmatch(s, "(.-)([%u%d][%u%d]+)") do
		if lower ~= "" then
			lower = pandoc.Str(lower)
			table.insert(split, lower)
    end
		upper = pandoc.SmallCaps(pandoc.text.lower(upper))
    table.insert(split, upper)
  end
  for leftover in string.gmatch(s, "[%u%d][%u%d]+(.-[^%u%s])$") do
    leftover = pandoc.Str(leftover)
    table.insert(split, leftover)
  end
  if #split == 0 then
    if s == "~" then s = "   " end -- sequence "space-nobreakspace-space"
    table.insert(split, pandoc.Str(s))
  end

	return split
end

function splitJudgement (line)
  local judgement = ""
  local first = pandoc.utils.stringify(line[1])
  if first == "^" then
    judgement = line[2]
    table.remove(line, 1)
    table.remove(line, 1)
    table.remove(line, 1)
  elseif string.sub(first, 1, 1) == "^" then
    judgement = pandoc.Str(string.sub(first, 2))
    table.remove(line, 1)
    table.remove(line, 1)
  end
  return judgement, line
end

------------------------
-- make markup in Pandoc
------------------------

function pandocMakeSingle (single, extraCols)
  -- Make just a single-line example
  local judge, data = splitJudgement(single)
  local line = { {pandoc.Plain(judge)}, {pandoc.Plain(data)} }

  -- add extra columns before
  -- either one (nummer) or two (nummer, letter)
  if extraCols > 0 then
  	for i=1,extraCols do
	  	table.insert(line, 1, {} )
    end
  end

  -- turn into Table
  local nCols = #line
  local rowContent = { line }
  local exampleSingle = turnIntoTable(rowContent, nCols, extraCols)
  return exampleSingle
end

function pandocMakeInterlinear (block, extraCols, formatOverride)
  -- Make interlinear gloss 4-liner from LineBlock input
  -- override format per example
  local globalFormatGloss = formatGloss
  if formatOverride ~= nil then
    formatGloss = (formatOverride == "true")
  end

  -- the four lines are: header, source, gloss and trans(lation)
  local header = { { pandoc.Plain(block[1]) } }
  table.insert(header, 1, {} )
  
  local judgeSource, source = splitJudgement(block[2])
	source = splitPara(source)
    if formatGloss then
      -- remove format at make emph throughout
      for i=1,#source do 
        local string = pandoc.utils.stringify(source[i])
        source[i] = { pandoc.Plain(pandoc.Emph(string)) }
      end
    end  
    table.insert(source, 1, { pandoc.Plain(judgeSource) } )

	local gloss = splitPara(block[3])
    if formatGloss then 
      -- remove format and turn capital-sequences into smallcaps
      for i=1,#gloss do 
        local string = pandoc.utils.stringify(gloss[i])
        gloss[i] = { pandoc.Plain(splitForSmallCaps(string)) }
      end 
    end 
    table.insert(gloss,  1, {} )

  local trans = block[#block]
    if formatGloss then
      -- remove quotes and add singlequote througout
      if trans[1].tag == "Quoted" then
        trans = trans[1].content
      end
      trans = {{ pandoc.Plain(pandoc.Quoted("SingleQuote", trans)) }}
    else 
      trans = {{ pandoc.Plain(trans) }} 
    end
    table.insert(trans,  1, {} )

  -- return to global setting
  if formatOverride ~= nil then
    formatGloss = globalFormatGloss
  end

	-- add extra columns before, either one or two
	for i=1,extraCols do
		table.insert(header, 1, {} )
		table.insert(source, 1, {} )
		table.insert(gloss,  1, {} )
		table.insert(trans,  1, {} )
  end
  
  -- turn into Table
  local nCols = math.max(#source, #gloss)
  local rowContent = {header, source, gloss, trans}
  local interlinear = turnIntoTable(rowContent, nCols, extraCols)

  -- make header and trans long cells
	interlinear.bodies[1].body[1][2][extraCols+2].col_span = nCols - extraCols - 1
  interlinear.bodies[1].body[#block][2][extraCols+2].col_span = nCols - extraCols - 1
  
	-- shift upwards when header is empty
	if next(block[1]) == nil then
		table.remove(interlinear.bodies[1].body, 1)
	end

	return interlinear
end

-- When multiple interlinears are combined, separate Tables are needed
-- also make separate Tables when single examples are mixed with interlinears

function pandocMakeList(data, number, formatOverride)
  -- make a list of tables
  local example = {}
  -- go through all items of the list
  for i=1,#data do
    
    if data[i][1].tag ~= "LineBlock" then
      example[i] = pandocMakeSingle(data[i][1].content, 2)
      -- add letter for sub-example in second column
      example[i].bodies[1].body[1][2][2].contents[1] = 
        pandoc.Plain(string.char(96+i)..".")

      if i>1 and data[i-1][1].tag ~= "LineBlock" then
        -- add tablerow to previous if also Plain/Para
        table.insert(example[i-1].bodies[1].body, example[i].bodies[1].body[1])
        -- exchange tables
        example[i] = example[i-1]
        example[i-1] = "ignore"
      end

    elseif data[i][1].tag == "LineBlock" then
      example[i] = pandocMakeInterlinear(data[i][1].content, 2, formatOverride)
      -- add letter for sub-example in second column
      example[i].bodies[1].body[1][2][2].contents[1] = 
        pandoc.Plain(string.char(96+i)..".")
    end
  end

  -- remove empty tables. Work around for `table.remove`
  local exampleList = {}
  for i=1,#example do
    if example[i] ~= "ignore" then
      table.insert(exampleList,example[i])
    end
  end

  -- keep track of judgements for better alignment
  local judgeSize = 0
  for i=1,#exampleList do
    for j=1,#exampleList[i].bodies[1].body do
      if exampleList[i].bodies[1].body[j][2][3].contents[1] ~= nil then
        local judge = pandoc.utils.stringify(exampleList[i].bodies[1].body[j][2][3].contents[1])
        judgeSize = math.max(judgeSize, utf8.len(judge))
      end
    end
  end

  -- rough approximations
  local spaceForNumber = string.rep(" ", 2*(string.len(number)+2))
  local spaceForLabel = tostring(15 + 5*judgeSize)
  if judgeSize == 0 then spaceForLabel = 0 end

  for i=1,#exampleList do
    -- For better alignment with example number, add invisibles in first column 
    -- not nice solution, but portable across formats
    exampleList[i].bodies[1].body[1][2][1].contents[1] = pandoc.Plain(spaceForNumber)
    -- For better alignment, add column-width to judgement column
    -- note: this is not portable outside html
    exampleList[i].bodies[1].body[1][2][3].attr = 
      pandoc.Attr(nil, { "linguistic-judgement" }, { width = spaceForLabel.."px"} )
  end

  return exampleList
end

function pandocMakeExample (data, number, formatOverride)
  -- make the examples as list of tables
  local example = {}
  local preamble = nil

  if #data == 2 then
    -- first part is assumed to be preamble
    preamble = data[1].content
    -- go on with second part
    data = { data[2] }
  end
    
  if data[1].tag == "Para" then
    -- make one-line example
    example[1] = pandocMakeSingle(data[1].content, 1)
  elseif data[1].tag == "LineBlock" then
    -- make one interlinear example
    example[1] = pandocMakeInterlinear(data[1].content, 1, formatOverride)
  elseif data[1].tag == "OrderedList" then
    -- make list of examples
    example = pandocMakeList(data[1].content, number, formatOverride)
  end
  
  if preamble ~= nil then
    -- How many positions should preamble be shifted to the left?
    local shift = 1
    if data[1].tag == "OrderedList" then shift = 0 end
    -- insert preamble as first row in example
    preamble = pandocMakeSingle(preamble, shift)
    table.insert(example[1].bodies[1].body, 1, preamble.bodies[1].body[1])
    -- make preamble multi-column
    local range = #example[1].colspecs - shift - 1
    example[1].bodies[1].body[1][2][2].col_span = range
  end

  -- Add example number to top left of first table
  local numberParen = pandoc.Plain( "("..number..")" )
  example[1].bodies[1].body[1][2][1].contents[1] = numberParen

  return example
end

--------------------------
-- make markup in Latex
-- using langsci-gb4e
--------------------------

-- convenience functions for Latex
function texFront (tex, pdoc)
  return table.insert(pdoc, 1, pandoc.RawInline("tex", tex))
end

function texEnd (tex, pdoc)
  return table.insert(pdoc, pandoc.RawInline("tex", tex))
end

-- this is not ideal. It is too complex to really get judgement layout to work
function texSplitJudgement (line)
  local judge, text = splitJudgement(line)
  if judge ~= "" then
    if latexPackage == "expex" then
      judge = pandoc.utils.stringify(judge)
      texFront("\\ljudge{"..judge.."} ", text)
    else
      table.insert(text, 1, judge)
    end
  end
  return text
end

-- different kinds of examples: single line, interlinear, list
function texMakeSingle (line)
  local example = texSplitJudgement(line)
  texFront("\n  ", example)
  return example
end

function texMakeInterlinear (block, exID, label, level, formatOverride )
  -- make one interlinear

  --check for local override of formatting
  local globalFormatGloss = formatGloss
  if formatOverride ~= nil then
    formatGloss = (formatOverride == "true")
  end

  -- the four lines are: header, source, gloss and trans(lation)
  local header = block[1]
  if level == 1 then label = "" end
  if latexPackage == "expex" then
    if #header > 1 then
      texFront("  "..label.."\n  \\begingl\n  \\glpreamble ", header)
      texEnd("//", header)
    else
      texFront("\n  "..label.."\n  \\begingl", header)
    end
  else
    --if level == 1 then
    --  texFront("\n  ", header)
    --else
      texFront("\n  "..label.."  ", header)
    --end
    -- langsci-gb4e behaves here different from gb4e
    if latexPackage == "langsci-gb4e" then
      if #header > 1 then
        texEnd("\\\\", header)
      end
    end
  end
  
  local source = texSplitJudgement (block[2])
  if formatGloss then
    for i=1,#source do
      if source[i].tag ~= "Space" then
        local string = pandoc.utils.stringify(source[i])
        source[i] = pandoc.Emph(string)
      end
    end
  end
  -- add latex
  if latexPackage == "expex" then
    texFront("\n  \\gla ", source)
    texEnd("//", source)
  else
    texFront("\n  \\gll ", source)
    texEnd("\\\\", source)
  end


  local gloss = block[3]
  if formatGloss then
    local result = pandoc.List()
    for i=1,#gloss do 
      local string = pandoc.utils.stringify(gloss[i])
      result:extend(splitForSmallCaps(string))
    end
    gloss = result
  end 
  -- add latex
  if latexPackage == "expex" then
    texFront("\n  \\glb ", gloss)
    texEnd("//", gloss)
  else
    texFront("\n       ",gloss)
    texEnd("\\\\", gloss)
  end

  local trans = block[4]
  if formatGloss then
    if trans[1].tag == "Quoted" then
      trans = trans[1].content
      texFront("`", trans)
      texEnd("'", trans)
    end
  end
  -- add latex
  if latexPackage == "expex" then
    texFront("\n  \\glft ", trans)
    texEnd("//\n  \\endgl", trans)
  else
    texFront("\n  \\glt ", trans)
  end

  -- return to global setting
  if formatOverride ~= nil then
    formatGloss = globalFormatGloss
  end

  -- combine for output
  local interlinear = header
  interlinear:extend(source)
  interlinear:extend(gloss)
  interlinear:extend(trans)
  return interlinear
end

function texMakeList (list, exID, formatOverride)
  local example = pandoc.List() 
  local labeltwo = ""

  for i=1,#list do

    if latexPackage == "linguex" then
      if i == 1 then labeltwo = "\\a." else labeltwo = "\\b." end
    elseif latexPackage:match "gb4e" then
      if i == 1 then labeltwo = "\\ea" else labeltwo = "\\ex" end
    elseif latexPackage == "expex" then
      labeltwo = "\\a"
    end

    if list[i][1].tag ~= "LineBlock" then
      local line = texSplitJudgement( list[i][1].content )
      texFront("\n  "..labeltwo.." ", line)
      example:extend(line)

    elseif list[i][1].tag == "LineBlock" then
      local line = texMakeInterlinear(list[i][1].content, exID, labeltwo, 2, formatOverride)
      if latexPackage:match "gb4e" then
        texFront("\n", line)
        texEnd("\n", line)
      end
      example:extend(line)
    end
  end
  return example
end

function texMakeExample (data, exID, formatOverride)
  local example = pandoc.List()

  -- different labeling for tex packages
  local labelone = ""
  if latexPackage == "linguex" then labelone = "\\ex."
  elseif latexPackage == "expex" then labelone = "\\ex"
  elseif latexPackage:match "gb4e" then labelone = "\\ea"
  end

  if #data == 2 then
    -- assume first part is header
    example = data[1].content
    -- and then proceed with second part
    data = { data[2] }
  end
 
  if data[1].tag == "Para" then
    -- example beginning
    if #example > 0 then texEnd("\\\\", example) end
    if latexPackage == "expex" then
      texFront(labelone.." <"..exID.."> ", example)
    else
      texFront(labelone.." \\label{"..exID.."} ", example)
    end
    -- add one-line example
    local line = texMakeSingle(data[1].content)
    example:extend(line)
    -- example ending
    if latexPackage:match "gb4e" then
      texEnd("\n\\z", example)
    elseif latexPackage == "expex" then
      texEnd("\n\\xe", example)
    end

  elseif data[1].tag == "LineBlock" then
    -- example beginning
    if latexPackage == "expex" then
      texFront(labelone.." <"..exID.."> ", example)
    else
      texFront(labelone.." \\label{"..exID.."} ", example)
    end
    -- add interlinear
    local interlinear = texMakeInterlinear(data[1].content, exID, labelone, 1, formatOverride)
    example:extend(interlinear)
    -- example ending
    if latexPackage:match "gb4e" then
      texEnd("\n  \\z", example)
    elseif latexPackage == "expex" then
      texEnd("\n\\xe", example)
    end

  elseif data[1].tag == "OrderedList" then
    -- example beginning
    if latexPackage == "expex" then
      texFront("\\pex <"..exID.."> ", example)
    else
      texFront(labelone.." \\label{"..exID.."} ", example)
    end
    -- add list of examples
    local list = texMakeList(data[1].content, exID, formatOverride)
    example:extend(list)
    -- example ending
    if latexPackage:match "gb4e" then
      texEnd("\n  \\z", example)
      texEnd("\n\\z", example)
    elseif latexPackage == "expex" then
      texEnd("\n\\xe", example)
    end
  end
  
  return pandoc.Plain(example)
end

--------------------------
-- format example from div
--------------------------

function makeExample (div)

  -- keep track of chapters (primary sections)
  if div.classes[1] == "section" then
    if div.attributes.number ~= nil and string.len(div.attributes.number) == 1 then
      chapter = chapter + 1
      counterInChapter = 0
    end
  end
 
  -- only do formatting for divs with class "ex"
  if div.classes[1] == "ex" then

	  -- keep count of examples
	  counter = counter + 1
    counterInChapter = counterInChapter + 1

    -- format the numbering
    local number = counter
    if addChapterNumber then
      number = chapter.."."..counterInChapter
    elseif restartAtChapter then
      number = counterInChapter
	  end

    -- make identifier for example
    -- or keep user-provided identifier
    local exID = ""
    if div.identifier == "" then
	  	exID = "ling-ex:"..chapter.."."..counterInChapter
	  else
	  	exID = div.identifier
	  end

    -- keep global index of ids/numbers for crossreference
    indexEx[exID] = number

    -- check format override per example
    local formatOverride = div.attributes['formatGloss']

    -- make different format for latex
    if FORMAT:match "latex" then
      return texMakeExample(div.content, exID, formatOverride)
    else
      local example = pandocMakeExample(div.content, number, formatOverride)
      -- add temporary Cite to resolve "Next"-type references in pandoc
      -- will be removed after cross-references are in place
      local tmpCite = pandoc.Cite({pandoc.Str("@Target")},{pandoc.Citation(exID,"NormalCitation")})
      
      return {
        pandoc.Plain(tmpCite),
        pandoc.Div(example, pandoc.Attr(exID) )
      }
    end
  end
end

-------------------------
-- format crossreferences
-------------------------

function uniqueNextrefs (cite)

  -- to resolve "Next"-style references give them all an unique ID
  -- make indices to check in which order they occur
  local nameN = string.match(cite.content[1].text, "([N]+)ext")
  local nameL = string.match(cite.content[1].text, "([L]+)ast")
  local target = string.match(cite.content[1].text, "@Target")

  -- use random ID to make unique
  if nameN ~= nil or nameL ~= nil then
    cite.citations[1].id = tostring(math.random(99999))
  end

  -- make indices
  if nameN ~= nil or nameL ~= nil or target ~= nil then
    orderInText = orderInText + 1
    indexRef[orderInText] = cite.citations[1].id
    rev_indexRef[cite.citations[1].id] = orderInText
  end

  return(cite)
end

function resolveNextrefs (cite)

  -- assume Next-style refs have numeric id (from uniqueNextrefs)
  -- assume Example-IDs are not numeric (user should not use them!)
  local id = cite.citations[1].id
  local order = rev_indexRef[id]

  local distN = 0
  local sequenceN = string.match(cite.content[1].text, "([N]+)ext")
  if sequenceN ~= nil then distN = string.len(sequenceN) end
  
  if distN > 0 then
    for i=order,#indexRef do
      if tonumber(indexRef[i]) == nil then
        distN = distN - 1
        if distN == 0 then
          cite.citations[1].id = indexRef[i]
        end
      end
    end
  end

  local distL = 0
  local sequenceL = string.match(cite.content[1].text, "([L]+)ast")
  if sequenceL ~= nil then distL= string.len(sequenceL) end
  
  if distL > 0 then
    for i=order,1,-1 do
      if tonumber(indexRef[i]) == nil then
        distL = distL - 1
        if distL == 0 then
          cite.citations[1].id = indexRef[i]
        end
      end
    end
  end

  return(cite)
end

function removeTmpTargetrefs (cite)
  -- remove temporary cites for resolving Next-style reference
  if cite.content[1].text == "@Target" then
    return pandoc.Plain({})
  end 
end

function makeCrossrefs (cite)

  local id = cite.citations[1].id
  local name = string.gsub(cite.content[1].text, "[%[%]@]", "")
  local suffix = ""
  local expexName = {Next = "nextx", NNext = "anextx", Last = "lastx", LLast = "blastx"}

  -- prevent Latex error when user sets xrefSuffixSep to space or nothing
  if FORMAT:match "latex" then
    if xrefSuffixSep == "" or xrefSuffixSep == " " or xrefSuffixSep == " " then 
      xrefSuffixSep = "\\," 
    end
  end

  -- only make suffix if there is something there
  if #cite.citations[1].suffix > 0 then
    suffix = pandoc.utils.stringify(cite.citations[1].suffix[2])
    suffix = xrefSuffixSep..suffix
  end

  -- make the cross-references
  if FORMAT:match "latex" then
    if latexPackage == "expex" then
      if string.match("@Next@NNext@Last@LLast", name) ~= nil then
        return pandoc.RawInline("latex", "({\\"..expexName[name].."}"..suffix..")")
      elseif indexEx[id] ~= nil then
        -- ignore other "cite" elements
        return pandoc.RawInline("latex", "(\\getref{"..id.."}"..suffix..")")
      end
    else
      if string.match("@Next@NNext@Last@LLast", name) ~= nil then
        -- let latex handle these
        return pandoc.RawInline("latex", "({\\"..name.."}"..suffix..")")
      elseif indexEx[id] ~= nil then
        -- ignore other "cite" elements
        return pandoc.RawInline("latex", "(\\ref{"..id.."}"..suffix..")")
      end
    end
  elseif indexEx[id] ~= nil then 
    -- ignore other "cite" elements
    return pandoc.Link("("..indexEx[id]..suffix..")", "#"..id)
  end

end

------------------------------------------
-- Pandoc trick to cycle through documents
------------------------------------------

return {
  -- preparations
  { Pandoc = addSectionNumbering },
  { Meta = getUserSettings },
  { Meta = addFormatting },
  -- formatting linguistic examples as tables
  { Div = makeExample },
  -- three passes necessary to resolve NNext-style references
  { Cite = uniqueNextrefs },
  { Cite = resolveNextrefs },
  { Cite = removeTmpTargetrefs },
  -- now finally all cross-references can be set
  { Cite = makeCrossrefs }
}
