DIFF ?= diff --strip-trailing-cr -u
LF	=	--lua-filter=table-short-captions.lua
F	=	-F pandoc-crossref

test: sample.md
	@pandoc -s $(LF) -t latex $< | \
		sh test-table-short-captions.sh

test-with-crossref: sample.md
	@pandoc -s $(LF) $(F) -t latex $< | \
		sh test-table-short-captions-crossref.sh

README.pdf: README.md
	@pandoc $(LF) $(F) $< -o $@

sample.tex: sample.md
	@pandoc -s $(LF) $(F) -t latex $< -o $@

sample.pdf: sample.md
	@pandoc -s $(LF) $(F) -t latex $< -o $@

clean:
	rm -v *.aux *.dvi *.fdb_latexmk *.fls *.log *.lot *.ps *.pdf sample.tex | true

.PHONY: test test-with-crossref clean
