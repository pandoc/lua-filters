DIFF ?= diff --strip-trailing-cr -u

test: test-html test-md

test-html:
	@pandoc --lua-filter=pagebreak.lua sample.md | $(DIFF) expected.html -

test-md:
	@pandoc -t ms --lua-filter=pagebreak.lua sample.md | $(DIFF) expected.ms -

.PHONY: test test-html test-md
