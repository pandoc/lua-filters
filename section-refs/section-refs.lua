function is_ref_div (blk)
   return (blk.t == "Div" and blk.identifier == "refs")
end

function is_ref_header (blk)
   return (blk.t == "Header" and blk.identifier == "bibliography")
end

function get_all_refs (blks)
   for _, b in pairs(blks) do
      if is_ref_div(b) then
	 return b.content
      end
   end
end

function remove_all_refs (blks)
   local out = {}
   for _, b in pairs(blks) do
      if not (is_ref_div(b) or is_ref_header(b)) then
	 table.insert(out, b)
      end
   end
   return out
end

-- We return a {number, ref} pair so we can sort in the individual
-- bibliographies.
function citation_to_numbered_ref (citation, all_refs)
   local div_id = "ref-" .. citation.id
   for i, d in ipairs(all_refs) do
      if d.t == "Div" and d.identifier == div_id then
	 return {i, d}
      end
   end
end


function get_partial_refs (blocks, all_refs)
   local cites = {}
   local citegetter = {
      Cite = function (el)
	 for _, c in pairs(el.citations) do
	    table.insert(cites, c)
	 end
      end
   }

   for _, b in pairs(blocks) do
      pandoc.walk_block(b, citegetter)
   end


   -- first we make a list of the {number, ref} pairs so we can sort
   -- them. Then after sorting, we're going to make a new list with
   -- only the second element.
   local numbered_refs = {}
   for _, c in pairs(cites) do
      local r = citation_to_numbered_ref(c, all_refs)
      if r then
	 table.insert(numbered_refs, r)
      end
   end

   table.sort(numbered_refs, function(x, y) return x[1] < y[1] end)

   local refs = {}
   for _, nr in pairs(numbered_refs) do
      table.insert(refs, nr[2])
   end

   return refs
end

function add_section_refs (blks, lvl, refs_title, all_refs)
   local output_blks = {}
   local section = {}
   local refs_num = 0

   local go = function ()
      refs_num = refs_num + 1
      local section_refs = get_partial_refs(section, all_refs)
      if refs_title then
	 local hdr = pandoc.Header(lvl + 1,
				   refs_title,
				   pandoc.Attr("bibliography-" .. tostring(refs_num),
					       {"unnumbered"}))
	 table.insert(section_refs, 1, hdr)
      end
      local refs_div = pandoc.Div(section_refs,
				  pandoc.Attr("refs-" .. tostring(refs_num),
					      {"references"}))
      table.insert(section, refs_div)
      for _, x in pairs(section) do
	 table.insert(output_blks, x)
      end
   end

   -- to avoid putting a bib after an intro paragraph.
   local seen_hdr_before = false
   for _, b in pairs(blks) do
      if b.t == "Header" and b.level <= lvl then
	 if seen_hdr_before then
	    go()
	    section = {b}
	 else
	    seen_hdr_before = true
	    table.insert(section, b)
	 end
      else
	 table.insert(section, b)
      end
   end
   go()
   return output_blks
end

function Pandoc(doc)
   if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
      io.stderr:write("WARNING: pandoc >= 2.1 required for section-refs filter\n")
      return doc
   end
   local refs_title = doc.meta["reference-section-title"]
   -- if we get it from a command-line field, read it in as md.
   if type(refs_title) == "string" then
      refs_title = pandoc.read(refs_title, "markdown").blocks[1].content
   end
   local lvl = tonumber(doc.meta["section-refs-level"]) or 1
   local all_refs = get_all_refs(doc.blocks)
   -- we only want to do something if there are refs to work
   -- with. This way, if this is run without pandoc-citeproc, it will
   -- just return the same document.
   if all_refs then
      local unreffed = remove_all_refs(doc.blocks)
      local output = add_section_refs(unreffed, lvl, refs_title, all_refs)
      return pandoc.Pandoc(output, doc.meta)
   end
end
