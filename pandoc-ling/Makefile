DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_html test_latex

test_html: README.md pandoc-ling.lua
	@pandoc --lua-filter pandoc-ling.lua --standalone --to=html $< \
	    | $(DIFF) expected.html -

test_latex: README.md pandoc-ling.lua
	@pandoc --lua-filter pandoc-ling.lua --standalone --to=latex $< \
	    | $(DIFF) expected.tex -

expected.html: README.md pandoc-ling.lua
	pandoc --lua-filter pandoc-ling.lua --standalone --output $@ $<

expected.tex: README.md pandoc-ling.lua
	pandoc --lua-filter pandoc-ling.lua --standalone --output $@ $<

.PHONY: test