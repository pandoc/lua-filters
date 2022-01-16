DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

.PHONY: test
test:
	@$(PANDOC) --lua-filter=spellcheck.lua sample.md | sort | $(DIFF) expected.txt -
