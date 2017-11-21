test:
	@pandoc --lua-filter=wordcount.lua sample.md | diff -u - expected.txt
