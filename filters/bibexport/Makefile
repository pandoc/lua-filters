test:
	@pandoc --lua-filter=bibexport.lua sample.md > /dev/null
	@diff -u bibexport.aux expected.bibexport.aux
	@diff -u bibexport.bib expected.bibexport.bib
	@rm -f bibexport.aux bibexport.bib
