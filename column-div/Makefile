DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex test_html

test_html: sample.md expected.html column-div.lua
	@pandoc -s --lua-filter column-div.lua --to=html $< \
		| $(DIFF) expected.html -

test_latex: sample.md expected.tex column-div.lua
	@pandoc --lua-filter column-div.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md column-div.lua
	pandoc -s --lua-filter column-div.lua --output $@ $<

expected.tex: sample.md column-div.lua
	pandoc --lua-filter column-div.lua --output $@ $<
