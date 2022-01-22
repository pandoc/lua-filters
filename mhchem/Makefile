DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) --lua-filter=mhchem.lua test.txt -o test.docx
	@rm -f test.native

.PHONY: test
