DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=styledh4.lua sample.md -t latex | $(DIFF) expected.latex -

.PHONY: test
