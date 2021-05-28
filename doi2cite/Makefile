DIFF ?= diff --strip-trailing-cr -u

test: sample1.md sample1.csl doi2cite.lua
	@pandoc --lua-filter=doi2cite.lua --to=markdown $< | $(DIFF) expected1.md -
	@pandoc --lua-filter=doi2cite.lua --to=pdf $< | $(DIFF) expected1.pdf -

expected1.md: sample1.md doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --wrap=preserve --output $@ $<

expected1.pdf: sample1.md sample1.csl doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --filter=pandoc-crossref --citeproc --csl=sample1.csl --output $@ $<

expected2.md: sample2.md doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --wrap=preserve --output $@ $<

.PHONY: test
