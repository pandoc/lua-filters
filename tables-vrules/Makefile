DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex

test_latex: sample.md expected.tex tables-rules.lua
	@pandoc -s --lua-filter tables-rules.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.tex: sample.md tables-rules.lua
	pandoc -s --lua-filter tables-rules.lua --output $@ $<
