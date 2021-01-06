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
local formatOverride = false -- to override setting 'formatGloss'

------------------------------------
-- User Settings with default values
------------------------------------

local formatGloss = false -- format interlinear examples
local xrefSuffixSep = " " -- &nbsp; separator to be inserted after number in example references
local restartAtChapter = false -- restart numbering at highest header without adding local chapternumbers
local addChapterNumber = false -- add chapternumbers to counting and restart at highest header
local latexPackage = "expex"
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
      .linguistic-example-content td { 
        padding-left: 2px;
        padding-right: 4px; 
      }
      .linguistic-example-judgement { 
        padding-right: 0; 
			}
			.linguistic-example-preamble {
				height: 1em;
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
			-- space for judgements
			add("\\newcommand{\\jdg}[1]{\\makebox[0.4em][r]{\\normalfont#1\\ignorespaces}}")
			-- chapternumbes
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
			add("\\lingset{ \
						belowglpreambleskip = -1.5ex, \
						aboveglftskip = -1.5ex, \
						exskip = 0ex, \
						interpartskip = -0.5ex, \
						belowpreambleskip = -2ex \
					}")
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

----------------------------
-- parse/rewrite example div
----------------------------

function processDiv (div)

	-- keep track of chapters (primary sections)
	if div.classes[1] == "section" then
		if div.attributes.number ~= nil and string.len(div.attributes.number) == 1 then
			chapter = chapter + 1
			counterInChapter = 0
		end
	end

	-- only do formatting for divs with class "ex"
	if div.classes[1] == "ex" then

		-- parse!
		local parsedDiv = parseDiv(div)

		-- add temporary Cite to resolve "Next"-type references
		-- will be removed after cross-references are in place
		local tmpCite = pandoc.Plain(pandoc.Cite(
						{pandoc.Str("@Target")},
						{pandoc.Citation(parsedDiv.exID,"NormalCitation")}))

		-- reformat!
		local example
		if FORMAT:match "latex" then
			example = texMakeExample(parsedDiv)
		else
			example = pandocMakeExample(parsedDiv)
			example = pandoc.Div(example, pandoc.Attr(parsedDiv.exID) )
		end

		return { tmpCite, example }
	end
end

------------
-- parse div
------------

function parseDiv (div)

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
	
	-- extract preamble
	local preamble = nil	
	local data = div.content[1]
	if #div.content== 2 then
		preamble = pandoc.Plain(div.content[1].content)
		data = div.content[2]
	end
	
	-- check format override per example
	local saveGlobalsetting = formatGloss
	formatGloss = div.attributes['formatGloss']

	-- extract judgements and content of examples
	local judgements = {}
	local examples = {}
	local kind = {}
	if data.tag == "OrderedList" then
		for i=1,#data.content do
			judgements[i], examples[i], kind[i] = parseExample(data.content[i][1])
		end
	else
		judgements[1], examples[1], kind[1] = parseExample(data)
	end

	-- return to global setting
	formatGloss = saveGlobalsetting

	return { 	kind = kind,
						preamble = preamble,   -- preamble is Plain
						judgements = judgements, -- judgements is list of Str
						examples = examples,   -- examples is list of (list of) Plain
						number = number,       -- number, exID are bare string
						exID = exID 
					}
end

----------------------------------
-- parse various kinds of examples
----------------------------------

function parseExample (data)

	local judgement, example, kind

	-- either a single line example
	if data.tag == "Para" or data.tag == "Plain" then
		judgement, example = splitJudgement(data.content)
		example = pandoc.Plain(example)
		kind = "single"

	-- or an interlinear example
	elseif data.tag == "LineBlock" then
		judgement, example = parseInterlinear(data.content)
		kind = "interlinear"
	end

	-- judgement is Str, example is (list of) Plain
	return judgement, example, kind
end

-------------------------------

function parseInterlinear (block)

	local interlinear = {}
	local judgement, source = splitJudgement( block[2] )

	-- header
	interlinear["header"] = pandoc.Plain( block[1] )
	-- source
	interlinear["source"] = splitSource(source)
	-- gloss
	interlinear["gloss"] = splitGloss( block[3] )
	-- translation
	interlinear["trans"] = getTrans( block[#block] )

	-- judgement is Str
	-- (header, trans) in interlinear is Plain
	-- (source, gloss) in interlinear is list of Plain
	return judgement, interlinear
end

----------------------------------------
-- helper functions to parse interlinear
----------------------------------------

function splitSource (line)
	local splitSource = splitPara(line)
  if formatGloss then
    -- remove format and make emph throughout
    for i=1,#splitSource do 
      local string = pandoc.utils.stringify(splitSource[i])
      splitSource[i] = pandoc.Plain(pandoc.Emph(string))
    end
	end
	-- list of Plain
	return splitSource
end

-------------------------------

function splitGloss (line)
	local splitGloss = splitPara(line)
  if formatGloss then 
    -- remove format and turn capital-sequences into smallcaps
    for i=1,#splitGloss do 
      local string = pandoc.utils.stringify(splitGloss[i])
      splitGloss[i] = pandoc.Plain(formatGlossLine(string))
    end 
	end 
	-- list of Plain
	return splitGloss
end

-------------------------------

function getTrans (line)
  if formatGloss then
    -- remove quotes and add singlequote througout
    if line[1].tag == "Quoted" then
      line = line[1].content
    end
		line = pandoc.Quoted("SingleQuote", line)
	end
	return pandoc.Plain(line)
end

------------------------------------------
-- helper functions for (lists of) inlines
------------------------------------------

function formatGlossLine (s)
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
	-- result is list of inlines
	return split
end

function splitPara (p)
	-- remove quotes, they interfere with the splitting
 if p[1].tag == "Quoted" then
	 p = p[1].content
 end
 -- push down emphasis to the individual words
 if p[1].tag == "Emph" then
	p = pandoc.walk_inline( p, { 
		Str = function(s) return Emph(s) end 
	} )
	end
  -- split paragraph in subtables at Space 
  -- to insert paragraph into pandoc.Table
  -- Is there a better way to do this in Pandoc-Lua?
  local start = 1
  local result = {}
  for i=1,#p do
 	 if p[i].tag == "Space" then
 		-- take everythins from start up to the space
 		 local chunk = table.move(p, start, i-1, 1, {})
 		 table.insert(result, pandoc.Plain(chunk) )
 		 -- move start to after space
 		 start = i + 1
 	 end
  end
  -- everything after the last space
  if start <= #p then
 	 local chunk = table.move(p, start, #p, 1, {})
 	 table.insert(result, pandoc.Plain(chunk) )
	end
	-- result is list of Plain chunks
  return result
end

function splitJudgement (line)
	local judgement = nil
	local first = pandoc.utils.stringify(line[1])
	-- complex judgements, e.g. with formatting
	if first == "^" then
		judgement = line[2]
		for i=1,3 do table.remove(line, 1) end
	-- simple judgement, only a string
	elseif string.sub(first, 1, 1) == "^" then
		judgement = pandoc.Str(string.sub(first, 2))
		for i=1,2 do table.remove(line, 1) end
	end
	-- judgement is Str, line is list of inlines
	return judgement, line
end

--------------
-- rewrite div
--------------

function pandocMakeExample (parsedDiv)

	-- sequences of 'single' will be combined into one output table
	local kind = parsedDiv.kind
	local onlySingle = true
	for i=1,#kind do
		if kind[i] ~= "single" then
			onlySingle = false
		end
	end

	-- prepare the examples for output as tables
	local example = {}
	if #kind == 1 and kind[1] == "single" then
		example[1] = pandocMakeSingle(parsedDiv)
	elseif #kind == 1 and kind[1] == "interlinear" then
		example[1] = pandocMakeInterlinear(parsedDiv)
	elseif #kind > 1 and onlySingle then
		example[1] = pandocMakeList(parsedDiv)
	else
		example = pandocMakeMixedList(parsedDiv)
	end

	-- Add example number to top left of first table
  local numberParen = pandoc.Plain( "("..parsedDiv.number..")" )
	example[1].bodies[1].body[1][2][1].contents[1] = numberParen
	-- set class for number
	example[1].bodies[1].body[1][2][1].attr = pandoc.Attr(nil, {"linguistic-example-number"})

	return example
end

function pandocMakeSingle (parsedDiv)

	-- basic content
	local exampleLine = parsedDiv.examples[1]
	local rowContent = { {{ exampleLine }} }
	-- set dimensions
	local nCols = 1
	local nRows = 1
	local judgeCol = 1
	-- add judgements
	local judgement = parsedDiv.judgements[1]
	if judgement ~= nil then 
		rowContent = addCol ( rowContent )
		nCols = nCols + 1
		judgeCol = judgeCol + 1
		rowContent[1][1][1] = pandoc.Plain(judgement)
	end
	-- add preamble
	local preamble = parsedDiv.preamble
	if preamble ~= nil then
		if judgement ~= nil then
			table.insert(rowContent, 1, { {}, { preamble } } )
		else
			table.insert(rowContent, 1, {{ preamble }} )
		end
		nRows = nRows + 1
	end
	-- add number column
	rowContent = addCol(rowContent)
	nCols = nCols + 1

	-- make into table
	local example = turnIntoTable(rowContent, nCols, judgeCol)

	-- set class of content
		example.bodies[1].body[nRows][2][nCols].attr = 
			pandoc.Attr(nil, {"linguistic-example-content"})
	-- set class of preamble
	if preamble ~= nil then
		example.bodies[1].body[1][2][nCols].attr = 
			pandoc.Attr(nil, {"linguistic-example-preamble"})
	end
	-- set class of judgment
		if judgeCol > 1 then
		example.bodies[1].body[2][2][judgeCol].attr = 
			pandoc.Attr(nil, {"linguistic-example-judgement"})
		end

	return example
end

function pandocMakeInterlinear (parsedDiv, label, forceJudge)

	-- basic content
	local selection = 1
	if label ~= nil then
		selection = label
	end
	local interlinear = parsedDiv.examples[selection]
	
	local header = {{ interlinear.header }}
	local source = interlinear.source 
	for i=1,#source do source[i] = { source[i] } end
	local gloss =  interlinear.gloss 
	for i=1,#gloss do gloss[i] = { gloss[i] } end
	local trans = {{ interlinear.trans  }}
	
	local rowContent = { trans }
		table.insert(rowContent, 1, gloss )
		table.insert(rowContent, 1, source )
	if header.content ~= nil then
		table.insert(rowContent, 1, header )
	end
	-- set dimenstions
	local nCols = #source
	local nRows = #rowContent
	local judgeCol = 0
	-- add judgements
	local judgement = parsedDiv.judgements[selection]
		if judgement ~= nil or forceJudge then 
			rowContent = addCol ( rowContent )
			nCols =  nCols + 1
			judgeCol = judgeCol + 2
			if judgement == nil then judgement = "" end
			if header.content ~= nil then
				rowContent[2][1][1] = pandoc.Plain(judgement)
			else
				rowContent[1][1][1] = pandoc.Plain(judgement)
			end
		end
	-- add labels
	if label ~= nil then
		rowContent = addCol(rowContent)
		rowContent[1][1][1] = pandoc.Plain(string.char(96+label)..".")
		nCols = nCols + 1
		judgeCol = judgeCol + 1
	end
	-- add preamble
	local preamble = parsedDiv.preamble
	if label ~= nil then preamble = nil end
	if preamble ~= nil then
		table.insert(rowContent, 1, {{ preamble }} )
		nRows = nRows + 1
	end
	-- add number column
	rowContent = addCol(rowContent)
	nCols = nCols + 1
	
	-- make into table
	local example = turnIntoTable(rowContent, nCols, judgeCol)

	local ps = 0 --preambleshift
	local ls = 0 --labelshift
	local hs = 0 --headershift
	local js = 0 --judgementshift
	if judgeCol > 1 then js = 1 end

	-- set class of preamble and extend cell
	if preamble ~= nil then
		ps = 1
		example.bodies[1].body[1][2][2].attr = 
			pandoc.Attr(nil, {"linguistic-example-preamble"})
		example.bodies[1].body[1][2][2].col_span = nCols - 1
	end
	-- set class of label
	if label ~= nil then
		ls = 1
		example.bodies[1].body[1][2][2+ps].attr = 
			pandoc.Attr(nil, {"linguistic-example-label"})
	end
	-- set class of header and extend cell
	if header.content ~= nil then
		hs = 1
		example.bodies[1].body[1+ps][2][2+ls+js].attr = 
			pandoc.Attr(nil, {"linguistic-example-header", "linguistic-example-content"})
		example.bodies[1].body[1+ps][2][2+ls+js].col_span = nCols-1-ls-js
	end
	-- set class of translation and extend cell
	example.bodies[1].body[nRows][2][2+ls+js].attr = 
		pandoc.Attr(nil, {"linguistic-example-translation", "linguistic-example-content"})
	example.bodies[1].body[nRows][2][2+ls+js].col_span = nCols-1-ls-js
	-- set class of judgment
	if judgeCol > 1 then
		example.bodies[1].body[1+hs+ps][2][2+ls].attr = 
			pandoc.Attr(nil, {"linguistic-example-judgement"})
	end
	-- set class of source and gloss
	local ssCol = 3 + ls -- sourcestart columns
	local ssRow = 1 + hs + ps -- sourcestart row
	for i=ssCol,nCols do
		example.bodies[1].body[ssRow][2][i].attr = 
			pandoc.Attr(nil, {"linguistic-example-source", "linguistic-example-content"})
		example.bodies[1].body[ssRow+1][2][i].attr = 
			pandoc.Attr(nil, {"linguistic-example-gloss", "linguistic-example-content"})
		end

	return example
end

function pandocMakeList (parsedDiv, from, to, forceJudge)
	-- for a group of subsequent single examples
	local lines = parsedDiv.examples
	local judgements = parsedDiv.judgements

	if from == nil then from = 1 end
	if to == nil then to = #lines end

	-- basic content
	local rowContent = { {{ lines[from] }} }
	for i=from+1,to do
		table.insert(rowContent, {{ lines[i] }} )
	end
	-- set dimensions
	local nCols = 1
	local nRows = #rowContent
	local judgeCol = 0
	-- add judgements
	for i=from,to do
		if judgements[i] ~= nil or forceJudge then 
			rowContent = addCol ( rowContent )
			nCols =  nCols + 1
			judgeCol = judgeCol + 2
			break
		end
	end
	for i=from,to do
		if judgements[i] ~= nil then
			rowContent[i][1][1] = pandoc.Plain(judgements[i])
		end
	end
	-- add labels
	local labels = {}
	for i=from,to do 
		local label = pandoc.Str(string.char(96+i)..".")
		table.insert(rowContent[i], 1, { pandoc.Plain(label) })
	end
		nCols = nCols + 1
		judgeCol = judgeCol + 1
	-- add preamble
	local preamble = parsedDiv.preamble
	if preamble ~= nil then
		table.insert(rowContent, 1, {{ preamble }} )
		nRows = nRows + 1
	end
	-- add number column
	rowContent = addCol(rowContent)
	nCols = nCols + 1

	-- make into table
	local example = turnIntoTable(rowContent, nCols, judgeCol)
	
	-- set class of content and labels
	local start = 1
	if preamble ~= nil then start = 2 end
	for i=start,nRows do
		example.bodies[1].body[i][2][nCols].attr = 
			pandoc.Attr(nil, {"linguistic-example-content"})
		example.bodies[1].body[i][2][2].attr = 
			pandoc.Attr(nil, {"linguistic-example-label"})
	end
	-- set class of judgment
	if judgeCol > 1 then
  	for i=start,#example.bodies[1].body do
			example.bodies[1].body[i][2][judgeCol].attr = 
				pandoc.Attr(nil, {"linguistic-example-judgement"})
		end
	end
	-- set class of preamble and extend cell
	if preamble ~= nil then
		example.bodies[1].body[1][2][2].attr = 
			pandoc.Attr(nil, {"linguistic-example-preamble"})
		example.bodies[1].body[1][2][2].col_span = nCols - 1
	end

	return example
end

-----------------------------------------

function pandocMakeMixedList (parsedDiv)

	-- mix of interlinear and (groups of) single examples
	-- returns a list of tables
	local result = {}
	local resultCount = 1
	local from = 1

	-- harmonize judgementcolumn across tables, possibly forced
	local judgements = parsedDiv.judgements
	local judgeSize = 0
	local forceJudge = false 
	for i=1,#judgements do
		judgeSize = math.max(judgeSize, utf8.len(judgements[i]))
	end
	--if judgeSize > 0 then 
		forceJudge = true
	--end

	for i=1,#parsedDiv.kind do
		if parsedDiv.kind[i] == "interlinear" then
			local label = i
			result[resultCount] = pandocMakeInterlinear(parsedDiv, label, forceJudge)
			resultCount = resultCount + 1
		elseif parsedDiv.kind[i] == "single" then
			if i==1 or parsedDiv.kind[i-1] ~= "single" then
				from = i
			elseif parsedDiv.kind[i+1] ~= "single" then
				local to = i
				result[resultCount] = pandocMakeList(parsedDiv, from, to, forceJudge)
				resultCount = resultCount + 1
			end
		end
	end

	-- rough approximations to align multiple tables
	local spaceForNumber = string.rep(" ", 2*(string.len(parsedDiv.number)+2))
	local spaceForJudge = tostring(15 + 5*judgeSize)
	
	for i=1,#result do
		-- For better alignment with example number
		-- add invisibles in first column 
    -- not a very elegant solution, but portable across formats
		result[i].bodies[1].body[1][2][1].contents[1] = 
			pandoc.Plain(spaceForNumber)
		-- For even better alignment, add column-width to judgement column
		-- note: this is probably not portable outside html
		if forceJudge then
	    result[i].bodies[1].body[2][2][3].attr = 
				pandoc.Attr(nil, { "linguistic-judgement" }, { width = spaceForJudge.."px"} )
		end
	end
	return result
end

--------------------------------------
-- helper functions to format examples
--------------------------------------

function addCol (lines)
	for i=1,#lines do
		table.insert(lines[i], 1, {})
	end
	return lines
end

function sLength (j)
	if j == nil then
		return 0
	else
		return utf8.len(pandoc.utils.stringify(j)) 
	end
end

-------------------------------

function turnIntoTable (rowContent, nCols, judgeCol)
  -- turn examples into Tables for alignment
  -- use simpleTable for construction
  local caption = {}
  local headers = {}
  local aligns = {}
		for i=1,nCols do aligns[i] = "AlignLeft" end
		if judgeCol > 1 then
	    aligns[judgeCol] = "AlignRight" -- Column for grammaticality judgements
		end
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
  result.attr = { class = "linguistic-example" }

  return result
end

--------------------------
-- make markup in Latex
-- using langsci-gb4e
--------------------------

-- convenience functions for Latex

function texFront (tex, pndc)
  return table.insert(pndc, 1, pandoc.RawInline("tex", tex))
end

function texEnd (tex, pndc)
  return table.insert(pndc, pandoc.RawInline("tex", tex))
end

function texCombine (separated)
	-- to align source/gloss they are separated
	-- for Latex, they have to returned to one object
	local result = pandoc.List()
	for i=1,#separated do 
		separated[i]=separated[i].content
		table.insert(separated[i], pandoc.Space())
		result:extend(separated[i])
	end
	return(result)
end

-- send request to different packages

function texMakeExample (parsedDiv)
	local result
	if latexPackage == "expex" then
		result = texMakeExpex(parsedDiv)
	elseif latexPackage == "linguex" then
		result = texMakeLinguex(parsedDiv)
	elseif latexPackage == "gb4e" then
		result = texMakeGb4e(parsedDiv)
	elseif latexPackage == "langsci-gb4e" then
		result = texMakeLangsci(parsedDiv)
	end
	return result
end

-------------------------
-- Different tex packages
-------------------------

function texMakeExpex (parsedDiv)

	-- prepare parsed chunks
	local kind = parsedDiv.kind
	local ID = parsedDiv.exID
	local preamble = parsedDiv.preamble
	local judgements = parsedDiv.judgements
	local line, header, source, gloss, trans

	if preamble == nil then 
		preamble = pandoc.List() 
	else 
		preamble = preamble.content
		texEnd("\\\\", preamble)
	end

	local judgeMax = ""
	for i=1,#kind do
		if sLength(judgements[i]) > sLength(judgeMax) then
			judgeMax = judgements[i]
		end
	end
	local judgeOffset = "[*="..pandoc.utils.stringify(judgeMax).."]"

	for i=1,#kind do
		if judgements[i] == nil then 
			judgements[i] = { pandoc.RawInline("tex","") }
		elseif #kind == 1 and kind[1] == "single" then
			judgements[i] = { judgements[i] }
			texFront("\n  \\judge{", judgements[i])
			texEnd("} ", judgements[i])
		else
			judgements[i] = { judgements[i] }
			texFront("\\ljudge{", judgements[i])
			texEnd("}", judgements[i])
		end
	end

	-- build Latex code starting with preamble and adding rest to it

	if #kind == 1 and kind[1] == "single" then
		texFront("\\ex<"..ID.."> ", preamble)
	elseif #kind ==1 and kind[1] == "interlinear" then
		texFront("\\ex"..judgeOffset.."<"..ID.."> ", preamble)
	else
		texFront("\\pex"..judgeOffset.."<"..ID.."> ", preamble)
	end

	for i=1,#kind do
		if kind[i] == "single" then

			line = parsedDiv.examples[i].content

			if #kind > 1 then 
				texFront("\n  \\a ", judgements[i])
			else 
				texFront("\n  ", judgements[i])
			end

			preamble:extend(judgements[i])
			preamble:extend(line)

		elseif kind[i] == "interlinear" then

			header = parsedDiv.examples[i].header.content
			source = parsedDiv.examples[i].source
			gloss  = parsedDiv.examples[i].gloss
			trans  = parsedDiv.examples[i].trans.content
			
			source = texCombine(source)
			gloss  = texCombine(gloss)

			if pandoc.utils.stringify(header) == "" then
				header = pandoc.List()
			else
				texFront("\n  \\glpreamble ", header)
				texEnd("//", header)
			end

			if #kind > 1 then 
				texEnd("\n  \\a ", preamble)
			end 

			texEnd("\n  \\begingl", preamble)
			preamble:extend(header)
			texFront("\n  \\gla ", judgements[i])
			preamble:extend(judgements[i])
			texEnd("//", source)
			preamble:extend(source)
			texFront("\n  \\glb ", gloss)
			texEnd("//", gloss)
			preamble:extend(gloss)
			texFront("\n  \\glft ", trans)
			texEnd("//", trans)
			preamble:extend(trans)
			texEnd("\n  \\endgl", preamble)

		end
	end
	texEnd("\n\\xe", preamble)
	return pandoc.Plain(preamble)
end

----------------------

function texMakeLinguex (parsedDiv)

	-- prepare parsed chunks
	local kind = parsedDiv.kind
	local ID = parsedDiv.exID
	local preamble = parsedDiv.preamble
	local judgements = parsedDiv.judgements
	local line, header, source, gloss, trans

	if preamble == nil then 
		preamble = pandoc.List() 
	else 
		preamble = preamble.content
		if #kind == 1 and kind[1] == "single" then
			texEnd("\\\\", preamble)
		end
	end

	for i=1,#kind do
		if judgements[i] == nil then 
			judgements[i] = { pandoc.RawInline("tex","") }
		else
			judgements[i] = { judgements[i] }
			texFront("\\jdg{", judgements[i])
			texEnd("}", judgements[i])
		end
	end

	-- build Latex code starting with preamble and adding rest to it
	texFront("\\ex. \\label{"..ID.."} ", preamble)

	for i=1,#kind do
		if kind[i] == "single" then

			line = parsedDiv.examples[i].content

			if #kind > 1 and i == 1 then 
				texFront("\n  \\a. ", judgements[i])
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\b. ", judgements[i])
			else
				texFront("\n  ", judgements[i])
			end

			preamble:extend(judgements[i])
			preamble:extend(line)

		elseif kind[i] == "interlinear" then

			header = parsedDiv.examples[i].header.content
			source = parsedDiv.examples[i].source
			gloss  = parsedDiv.examples[i].gloss
			trans  = parsedDiv.examples[i].trans.content
			
			source = texCombine(source)
			gloss  = texCombine(gloss)

			if pandoc.utils.stringify(header) == "" then
				header = pandoc.List()
			end

			if #kind > 1 and i == 1 then 
				texFront("\n  \\a. ", header)
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\b. ", header)
			else
				texFront("\n  ", header)
			end

			preamble:extend(header)
			texFront("\n  \\gll ", judgements[i])
			preamble:extend(judgements[i])
			texEnd("\\\\", source)
			preamble:extend(source)
			texFront("\n       ", gloss)
			texEnd("\\\\", gloss)
			preamble:extend(gloss)
			texFront("\n  \\glt ", trans)
			preamble:extend(trans)

		end
	end
	return pandoc.Plain(preamble)
end

----------------------

function texMakeGb4e (parsedDiv)

	-- prepare parsed chunks
	local kind = parsedDiv.kind
	local ID = parsedDiv.exID
	local preamble = parsedDiv.preamble
	local nopreamble
	local judgements = parsedDiv.judgements
	local line, header, source, gloss, trans

	if preamble == nil then 
		preamble = pandoc.List() 
		nopreamble = true
	else 
		preamble = preamble.content
	end

	local judgeMax = ""
	for i=1,#kind do
		if sLength(judgements[i]) > sLength(judgeMax) then
			judgeMax = judgements[i]
		end
	end
	local judgeOffset = "\\judgewidth{"..pandoc.utils.stringify(judgeMax).."}"

	for i=1,#kind do
		if judgements[i] == nil then 
			judgements[i] = { pandoc.RawInline("tex","[] { ") }
		else
			judgements[i] = { judgements[i] }
			texFront("[", judgements[i])
			texEnd("] { ", judgements[i])
		end
	end

	-- build Latex code starting with preamble and adding rest to it
		texFront("\\begin{exe} "..judgeOffset.." \\label{"..ID.."} \n  \\ex ", preamble)

	for i=1,#kind do
		if kind[i] == "single" then

			line = parsedDiv.examples[i].content
			
			if #kind > 1 and i == 1 then 
				texFront("\n  \\begin{xlist}\n  \\ex ", judgements[i])
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\ex ", judgements[i])
			elseif #kind ==1 and nopreamble then
					texFront("", judgements[i])
			else
					texFront("\n  \\sn ", judgements[i])
			end
			
			preamble:extend(judgements[i])
			preamble:extend(line)
			texEnd(" }", preamble)

		elseif kind[i] == "interlinear" then

			header = parsedDiv.examples[i].header.content
			source = parsedDiv.examples[i].source
			gloss  = parsedDiv.examples[i].gloss
			trans  = parsedDiv.examples[i].trans.content
			
			source = texCombine(source)
			gloss  = texCombine(gloss)

			if pandoc.utils.stringify(header) == "" then
				header = pandoc.List()
			else texFront("\n       ", header)
			end

			if #kind > 1 and i == 1 then 
				texFront("\n      \\begin{xlist}\n  \\ex ", judgements[i])
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\ex ", judgements[i])
			else
				texFront("", judgements[i])
			end

			preamble:extend(judgements[i])
			preamble:extend(header)
			texFront("\n  \\gll ", source)
			texEnd("\\\\", source)
			preamble:extend(source)
			texFront("\n       ", gloss)
			texEnd("\\\\", gloss)
			preamble:extend(gloss)
			texFront("\n  \\glt ", trans)
			preamble:extend(trans)
			texEnd(" }", preamble)

		end
	end
	if #kind > 1 then texEnd("\n  \\end{xlist}", preamble) end
	texEnd("\n\\end{exe}", preamble)
	return pandoc.Plain(preamble)
end

----------------------

function texMakeLangsci (parsedDiv)

	-- prepare parsed chunks
	local kind = parsedDiv.kind
	local ID = parsedDiv.exID
	local preamble = parsedDiv.preamble
	local nopreamble
	local judgements = parsedDiv.judgements
	local line, header, source, gloss, trans

	if preamble == nil then 
		preamble = pandoc.List() 
		nopreamble = true
	else 
		preamble = preamble.content
	end

	local judgeMax = ""
	for i=1,#kind do
		if sLength(judgements[i]) > sLength(judgeMax) then
			judgeMax = judgements[i]
		end
	end
	local judgeOffset = "\\judgewidth{"..pandoc.utils.stringify(judgeMax).."}"

	for i=1,#kind do
		if judgements[i] == nil then
			if #kind == 1 and kind[1] == "single" then
				judgements[i] = { pandoc.RawInline("tex","") }
			else
				judgements[i] = { pandoc.RawInline("tex","[] { ") }
			end
		else
			judgements[i] = { judgements[i] }
			if #kind > 1 or kind[1] == "interlinear" then
				texFront("[", judgements[i])
				texEnd("] { ", judgements[i])
			end
		end
	end

	-- build Latex code starting with preamble and adding rest to it
	if #kind == 1 and kind[1] == "interlinear" then
		texFront("\\ea ", judgements[1])
		local tmp = pandoc.List()
		tmp:extend(judgements[1])
		texFront(judgeOffset.." \\label{"..ID.."} ", preamble)
		tmp:extend(preamble)
		preamble = tmp
	else
		texFront("\\ea "..judgeOffset.." \\label{"..ID.."} ", preamble)
	end

	for i=1,#kind do
		if kind[i] == "single" then

			line = parsedDiv.examples[i].content
			
			if #kind == 1 and nopreamble ~= true then
				texEnd("\\\\", preamble)
			end

			if #kind > 1 and i == 1 then 
				texFront("\n  \\ea ", judgements[i])
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\ex ", judgements[i])
			else
				texFront("\n  ", judgements[i])
			end
			
			preamble:extend(judgements[i])
			preamble:extend(line)

			if #kind > 1 then
				texEnd(" }", preamble)
			end

		elseif kind[i] == "interlinear" then

			header = parsedDiv.examples[i].header.content
			source = parsedDiv.examples[i].source
			gloss  = parsedDiv.examples[i].gloss
			trans  = parsedDiv.examples[i].trans.content
			
			source = texCombine(source)
			gloss  = texCombine(gloss)

			if pandoc.utils.stringify(header) == "" then
				header = pandoc.List()
			else 
				texFront("\n       ", header)
				texEnd("\\\\", header)
			end

			if #kind > 1 and i == 1 then 
				texFront("\n  \\ea ", judgements[i])
				preamble:extend(judgements[i])
			elseif #kind > 1 and i > 1 then
				texFront("\n  \\ex ", judgements[i])
				preamble:extend(judgements[i])
			end

			preamble:extend(header)
			texFront("\n  \\gll ", source)
			texEnd("\\\\", source)
			preamble:extend(source)
			texFront("\n       ", gloss)
			texEnd("\\\\", gloss)
			preamble:extend(gloss)
			texFront("\n  \\glt ", trans)
			preamble:extend(trans)
			texEnd(" }", preamble)

		end
	end
	if #kind > 1 then texEnd("\n  \\z", preamble) end
	texEnd("\n\\z", preamble)
	return pandoc.Plain(preamble)
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

------------------------------------------

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

------------------------------------------

function removeTmpTargetrefs (cite)
  -- remove temporary cites for resolving Next-style reference
  if cite.content[1].text == "@Target" then
    return pandoc.Plain({})
  end 
end

------------------------------------------

function makeCrossrefs (cite)

  local id = cite.citations[1].id
  local suffix = ""

  -- only make suffix if there is something there
  if #cite.citations[1].suffix > 0 then
    suffix = pandoc.utils.stringify(cite.citations[1].suffix[2])
    suffix = xrefSuffixSep..suffix
  end

	-- prevent Latex error when user sets xrefSuffixSep to space or nothing
	if FORMAT:match "latex" then
		if xrefSuffixSep == "" or -- empty
			 xrefSuffixSep == " " or -- space
			 xrefSuffixSep == " " then -- non-breaking space
			xrefSuffixSep = "\\," -- set to thin space
		end
	end

	-- make the cross-references
  if indexEx[id] ~= nil then -- ignore other "cite" elements
		if FORMAT:match "latex" then
			if latexPackage == "expex" then
				return pandoc.RawInline("latex", "(\\getref{"..id.."}"..suffix..")")
			else
				return pandoc.RawInline("latex", "(\\ref{"..id.."}"..suffix..")")
			end
		else	
			return pandoc.Link("("..indexEx[id]..suffix..")", "#"..id)
		end
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
	-- parse examples and rewrite
	{ Div = processDiv },
	 -- three passes necessary to resolve NNext-style references
	 { Cite = uniqueNextrefs },
	 { Cite = resolveNextrefs },
	 { Cite = removeTmpTargetrefs },
	 -- now finally all cross-references can be set
	 { Cite = makeCrossrefs }
}




