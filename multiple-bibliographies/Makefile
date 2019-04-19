DIFF ?= diff --strip-trailing-cr -u

test: sample.md multiple-bibliographies.lua
	@pandoc --lua-filter=multiple-bibliographies.lua \
	        --standalone --to=native $< 2>/dev/null \
	    | $(DIFF) - expected.native

.PHONY: test
