DIFF ?= diff --strip-trailing-cr -u

.PHONY: test
test:
	@pandoc --lua-filter=spellcheck.lua sample.md | sort | $(DIFF) expected.txt -
