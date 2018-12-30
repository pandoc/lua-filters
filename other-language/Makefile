test:
	@pandoc --lua-filter=other-language.lua --output=output.tex sample.md
	@diff -u expected.tex output.tex
	@rm -f output.tex

.PHONY: test
