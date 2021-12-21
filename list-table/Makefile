DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md expected.html list-table.lua
	@$(PANDOC) --lua-filter list-table.lua --to=html $< \
		| $(DIFF) expected.html -

.PHONY: test
