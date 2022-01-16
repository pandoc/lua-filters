DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=cito.lua --output=output.md --standalone sample.md
	@$(DIFF) expected.md output.md
	@rm -f output.md

.PHONY: test
