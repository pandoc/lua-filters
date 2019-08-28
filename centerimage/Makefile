DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=centerimage.lua sample.md -t latex | $(DIFF) expected.latex -

.PHONY: test

debug:
	@pandoc --lua-filter=centerimage.lua sample.md -t latex

.PHONY: debug
