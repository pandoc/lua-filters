DIFF ?= diff --strip-trailing-cr -u

test: sample.md author-info-blocks.lua
	@pandoc --lua-filter=author-info-blocks.lua --standalone --to=native $< \
	    | $(DIFF) expected.native -

expected.native: sample.md author-info-blocks.lua
	pandoc --lua-filter=author-info-blocks.lua --standalone --output $@ $<

.PHONY: test
