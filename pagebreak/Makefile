DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=pagebreak.lua sample.md | $(DIFF) expected.html -

.PHONY: test
