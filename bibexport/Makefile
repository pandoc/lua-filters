test:
	@pandoc --lua-filter=bibexport.lua sample.md > /dev/null
	@diff --strip-trailing-cr -u bibexport.aux expected.bibexport.aux
	@diff --strip-trailing-cr -u bibexport.bib expected.bibexport.bib
	@rm -f bibexport.aux bibexport.bib
