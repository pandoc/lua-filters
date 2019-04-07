LF	=	--lua-filter=table-short-captions.lua
F	=	-F pandoc-crossref

test: sample.md
	@pandoc -s $(LF) -t native $< | \
		diff -u expected-sample.native -

test-with-crossref: sample.md
	@pandoc -s $(LF) $(F) -t latex $< | \
		diff -u expected-sample.tex -

README.pdf: README.md
	@pandoc $(LF) $(F) $< -o $@

sample.tex: sample.md
	@pandoc -s $(LF) $(F) -t latex $< -o $@

sample.pdf: sample.md
	@pandoc -s $(LF) $(F) -t latex $< -o $@

clean:
	rm -v *.aux *.dvi *.fdb_latexmk *.fls *.log *.lot *.ps *.pdf sample.tex | true

.PHONY: test test-with-crossref clean
