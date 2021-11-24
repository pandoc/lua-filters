DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md multiple-bibliographies.lua
	@$(PANDOC) \
		--lua-filter=multiple-bibliographies.lua \
		--standalone \
		--to=native $< \
	    | $(DIFF) - expected.native

.PHONY: test
