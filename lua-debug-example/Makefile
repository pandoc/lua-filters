DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=lua-debug-example.lua sample.md | $(DIFF) expected.html -

.PHONY: test
