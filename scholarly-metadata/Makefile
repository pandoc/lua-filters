DIFF ?= diff --strip-trailing-cr -u

test: sample.md scholarly-metadata.lua
	@pandoc --lua-filter=scholarly-metadata.lua --standalone --to=markdown $< \
	    | $(DIFF) expected.md -

expected.md: sample.md scholarly-metadata.lua
	pandoc --lua-filter=scholarly-metadata.lua --standalone --output $@ $<

.PHONY: test
