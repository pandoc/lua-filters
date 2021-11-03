DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=bibexport.lua sample.md > /dev/null
	@$(DIFF) bibexport.aux expected.bibexport.aux
	@$(DIFF) bibexport.bib expected.bibexport.bib
	@rm -f bibexport.aux bibexport.bib
