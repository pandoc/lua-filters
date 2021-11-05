DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample-document.md include-meta.lua
	@$(PANDOC) --lua-filter=include-meta.lua --standalone --to=markdown $< \
		| $(DIFF) expected.md -

expected.md: sample-document.md include-meta.lua
	$(PANDOC) --lua-filter=include-meta.lua --standalone --output $@ $<

.PHONY: test

