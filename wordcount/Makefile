DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=wordcount.lua sample.md | $(DIFF) expected.txt -

.PHONY: test
