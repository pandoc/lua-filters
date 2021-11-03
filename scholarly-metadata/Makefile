DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md scholarly-metadata.lua
	@$(PANDOC) --lua-filter=scholarly-metadata.lua --standalone --to=markdown $< \
	    | $(DIFF) expected.md -

expected.md: sample.md scholarly-metadata.lua
	$(PANDOC) --lua-filter=scholarly-metadata.lua --standalone --output $@ $<

.PHONY: test
