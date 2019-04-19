DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=wordcount.lua sample.md | $(DIFF) expected.txt -

.PHONY: test
