DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex

test_latex: sample.md expected.tex longtable-to-xtab.lua
	@pandoc --lua-filter longtable-to-xtab.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.tex: sample.md longtable-to-xtab.lua
	pandoc --lua-filter longtable-to-xtab.lua --output $@ $<
