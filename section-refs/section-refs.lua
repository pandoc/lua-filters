-- pandoc.utils.make_sections exists since pandoc 2.8
if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
  error("ERROR: pandoc >= 2.1 required for section-refs filter")
else
  PANDOC_VERSION:must_be_at_least {2,8}
end

local utils = require 'pandoc.utils'
local run_json_filter = utils.run_json_filter

--- The document's metadata
local meta
-- Lowest level at which bibliographies should be generated.
local section_refs_level
-- original bibliography value
local orig_bibliography

-- Returns true iff a div is a section div.
local function is_section_div (div)
  return div.t == 'Div'
    and div.classes[1] == 'section'
    and div.attributes.number
end

local function section_header (div)
  local header = div.content and div.content[1]
  local is_header = is_section_div(div)
    and header
    and header.t == 'Header'
  return is_header and header or nil
end

local function adjust_refs_components (div)
  local header = section_header(div)
  if not header then
    return div
  end
  local blocks = div.content
  local bib_header = blocks:find_if(function (b)
      return b.identifier == 'bibliography'
  end)
  local refs = blocks:find_if(function (b)
      return b.identifier == 'refs'
  end)
  if bib_header then
    bib_header.identifier = 'bibliography-' .. header.attributes.number
    bib_header.level = header.level + 1
  end
  if refs and refs.identifier == 'refs' then
    refs.identifier = 'refs-' .. header.attributes.number
  end
  return div
end

local function run_citeproc (doc)
  if PANDOC_VERSION >= '2.11' then
    local args = {'--from=json', '--to=json', '--citeproc'}
    return run_json_filter(doc, 'pandoc', args)
  else
    return run_json_filter(doc, 'pandoc-citeproc', {FORMAT, '-q'})
  end
end

--- Create a bibliography for a given topic. This acts on all
-- section divs at or above `section_refs_level`
local function create_section_bibliography (div)
  -- don't do anything if there is no bibliography
  if not meta.bibliography and not meta.references then
    return nil
  end
  local header = section_header(div)
  -- Blocks for which a bibliography will be generated
  local subsections
  local blocks
  if not header or section_refs_level < header.level then
    -- Don't do anything for lower level sections.
    return nil
  elseif section_refs_level == header.level then
    blocks = div.content
    subsections = pandoc.List:new{}
  else
    blocks = div.content:filter(function (b)
        return not is_section_div(b)
    end)
    subsections = div.content:filter(is_section_div)
  end
  local tmp_doc = pandoc.Pandoc(blocks, meta)
  local new_doc = run_citeproc(tmp_doc)
  div.content = new_doc.blocks .. subsections
  return adjust_refs_components(div)
end

--- Remove remaining section divs
local function flatten_sections (div)
  local header = section_header(div)
  if not header then
    return nil
  else
    header.identifier = div.identifier
    header.attributes.number = nil
    div.content[1] = header
    return div.content
  end
end

--- Filter to the references div and bibliography header added by
--- pandoc-citeproc.
local remove_pandoc_citeproc_results = {
  Header = function (header)
    return header.identifier == 'bibliography'
      and {}
      or nil
  end,
  Div = function (div)
    return div.identifier == 'refs'
      and {}
      or nil
  end
}

local function restore_bibliography (meta)
  meta.bibliography = orig_bibliography
  return meta
end

--- Setup the document for further processing by wrapping all
--- sections in Div elements.
function setup_document (doc)
  -- save meta for other filter functions
  meta = doc.meta
  section_refs_level = tonumber(meta["section-refs-level"]) or 1
  orig_bibliography = meta.bibliography
  meta.bibliography = meta['section-refs-bibliography'] or meta.bibliography
  local sections = utils.make_sections(true, nil, doc.blocks)
  return pandoc.Pandoc(sections, doc.meta)
end

return {
  -- remove result of previous pandoc-citeproc run (for backwards
  -- compatibility)
  remove_pandoc_citeproc_results,
  {Pandoc = setup_document},
  {Div = create_section_bibliography},
  {Div = flatten_sections, Meta = restore_bibliography}
}
