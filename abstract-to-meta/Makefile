DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample1.md sample2.md abstract-to-meta.lua
	@$(PANDOC) --lua-filter=abstract-to-meta.lua --standalone --to=markdown \
		sample1.md | $(DIFF) expected1.md -
	@$(PANDOC) --lua-filter=abstract-to-meta.lua --standalone --to=markdown \
		sample2.md | $(DIFF) expected2.md -

expected: sample1.md expected1.md sample2.md expected2.md abstract-to-meta.lua

expected1.md: sample1.md abstract-to-meta.lua
	$(PANDOC) --lua-filter=abstract-to-meta.lua --standalone --output $@ $<

expected2.md: sample2.md abstract-to-meta.lua
	$(PANDOC) --lua-filter=abstract-to-meta.lua --standalone --output $@ $<

.PHONY: test
