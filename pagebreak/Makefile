test:
	@pandoc --lua-filter=pagebreak.lua sample.md | diff -u expected.html -

.PHONY: test
