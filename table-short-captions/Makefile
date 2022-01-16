DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc
LF	=	--lua-filter=table-short-captions.lua
F	=	-F pandoc-crossref

test: sample.md
	@$(PANDOC) -s $(LF) -t latex $< | \
		sh test-table-short-captions.sh

test-with-crossref: sample.md
	@$(PANDOC) -s $(LF) $(F) -t latex $< | \
		sh test-table-short-captions-crossref.sh

README.pdf: README.md
	@$(PANDOC) $(LF) $(F) $< -o $@

sample.tex: sample.md
	@$(PANDOC) -s $(LF) $(F) -t latex $< -o $@

sample.pdf: sample.md
	@$(PANDOC) -s $(LF) $(F) -t latex $< -o $@

clean:
	rm -fv *.aux *.dvi *.fdb_latexmk *.fls *.log *.lot *.ps *.pdf sample.tex

.PHONY: test test-with-crossref clean
