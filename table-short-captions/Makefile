LF	=	--lua-filter=table-short-captions.lua
F	=	-F pandoc-crossref

readme:
	@pandoc -s $(LF) $(F)  README.md -o README.pdf

sample:
	@pandoc -s $(LF) $(F) -t latex sample.md -o sample.tex
	@pandoc -s $(LF) $(F) -t latex sample.md -o sample.pdf

test: sample
	diff --strip-trailing-cr expected-sample.tex sample.tex

clean:
	rm -v *.aux *.dvi *.fdb_latexmk *.fls *.log *.lot *.ps *.pdf sample.tex | true
