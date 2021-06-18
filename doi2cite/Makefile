DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=doi2cite.lua --wrap=preserve --output=output.md sample1.md
	@$(DIFF) expected1.md output.md
	@rm -f output.md

expected1.md: sample1.md doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --wrap=preserve --output $@ $<

expected1.pdf: sample1.md sample1.csl doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --filter=pandoc-crossref --citeproc --csl=sample1.csl --output $@ $<

expected2.md: sample2.md doi2cite.lua
	pandoc --lua-filter=doi2cite.lua --wrap=preserve --output $@ $<

clean:
	@rm -f expected1.md
	@rm -f expected2.md
	@rm -f expected1.pdf

.PHONY: test
