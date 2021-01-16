DIFF ?= diff --strip-trailing-cr -u

test: test-asciidoc test-html test-md 

test-asciidoc:
	@pandoc --lua-filter=pagebreak.lua sample.md --to asciidoc | $(DIFF) expected.adoc -

test-html:
	@pandoc --lua-filter=pagebreak.lua sample.md | $(DIFF) expected.html -

test-md:
	@pandoc -t ms --lua-filter=pagebreak.lua sample.md | $(DIFF) expected.ms -

.PHONY: test test-asciidoc test-html test-md 
