test:
	@pandoc --lua-filter=spellcheck.lua sample.md | sort | diff -u - expected.txt
