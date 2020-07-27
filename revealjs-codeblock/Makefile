DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=revealjs-codeblock.lua sample.md -t revealjs | $(DIFF) expected.html -

.PHONY: test