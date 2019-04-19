DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=cito.lua --output=output.md --standalone sample.md
	@$(DIFF) expected.md output.md
	@rm -f output.md

.PHONY: test
