DIFF ?= diff --strip-trailing-cr -u

test: sample.md author-info-blocks.lua
	@pandoc --lua-filter=author-info-blocks.lua --standalone --to=native $< \
	    | $(DIFF) expected.native -

expected.native: sample.md author-info-blocks.lua
	pandoc --lua-filter=author-info-blocks.lua --standalone --output $@ $<

sample.pdf: sample.md author-info-blocks.lua
	@pandoc \
	    --lua-filter=author-info-blocks.lua \
	    --output $@ $<

sample.png: sample.pdf
	@# somewhat crude method of converting to PDF, removing the page number
	@# and trimming the image to the title block.
	@convert -density 300 $< -shave 0%x15% -trim -border 5% $@

.PHONY: test
