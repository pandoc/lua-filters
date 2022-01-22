DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex

test_latex: sample.md expected.tex tables-vrules.lua
	@pandoc --lua-filter tables-vrules.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.tex: sample.md tables-vrules.lua
	pandoc --lua-filter tables-vrules.lua --output $@ $<
