DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=latex-hyphen.lua --output=output.tex sample.md
	@$(DIFF) expected.tex output.tex
	@rm -f output.tex

.PHONY: test
