DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=revealjs-codeblock.lua sample.md -t revealjs | \
		$(DIFF) expected.html -

.PHONY: test
