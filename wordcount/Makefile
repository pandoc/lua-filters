test:
	@pandoc --lua-filter=wordcount.lua sample.md | diff --strip-trailing-cr -u - expected.txt
