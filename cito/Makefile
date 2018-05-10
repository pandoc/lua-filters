test:
	@pandoc --lua-filter=cito.lua --output=output.md --standalone sample.md
	@diff -u expected.md output.md
	@rm -f output.md

.PHONY: test
