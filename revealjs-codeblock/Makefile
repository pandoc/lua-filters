DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=revealjs-codeblock.lua \
	        --to=revealjs \
	        --wrap=none \
	        sample.md | \
		$(DIFF) expected.html -

.PHONY: test
