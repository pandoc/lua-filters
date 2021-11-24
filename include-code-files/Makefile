DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md include-code-files.lua
	@$(PANDOC) --lua-filter=include-code-files.lua --to=native $< \
	    | $(DIFF) expected.native -

expected.native: sample.md include-code-files.lua
	$(PANDOC) --lua-filter=include-code-files.lua --output $@ $<

.PHONY: test
