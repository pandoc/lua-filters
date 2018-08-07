test:
	@pandoc --lua-filter=spellcheck.lua sample.md | sort | diff --strip-trailing-cr -u expected.txt -
