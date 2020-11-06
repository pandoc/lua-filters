DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=pandocVlna.lua sampleCZ.md | $(DIFF) expectedCZ.html -
	@pandoc --lua-filter=pandocVlna.lua sampleEN.md | $(DIFF) expectedEN.html -
.PHONY: test
