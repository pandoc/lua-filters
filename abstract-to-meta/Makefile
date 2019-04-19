DIFF ?= diff --strip-trailing-cr -u

test: sample.md abstract-to-meta.lua
	@pandoc --lua-filter=abstract-to-meta.lua --standalone --to=markdown $< \
	    | $(DIFF) expected.md -

expected.md: sample.md abstract-to-meta.lua
	pandoc --lua-filter=abstract-to-meta.lua --standalone --output $@ $<

.PHONY: test
