DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: test-asciidoc test-html test-md

test-asciidoc:
	@$(PANDOC) --lua-filter=pagebreak.lua sample.md --to asciidoc | \
	  $(DIFF) expected.adoc -

test-html:
	@$(PANDOC) --lua-filter=pagebreak.lua --wrap=none sample.md | \
	  $(DIFF) expected.html -

test-md:
	@$(PANDOC) -t ms --lua-filter=pagebreak.lua sample.md | \
	  $(DIFF) expected.ms -

.PHONY: test test-asciidoc test-html test-md
