DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

.PHONY: test

test: test_latex test_html

test_html: sample.md first-line-indent.lua
	@$(PANDOC) -s --lua-filter first-line-indent.lua --to=html $< \
		| $(DIFF) expected.html -

test_latex: sample.md first-line-indent.lua
	@$(PANDOC) -s --lua-filter first-line-indent.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md first-line-indent.lua
	$(PANDOC) -s --lua-filter first-line-indent.lua --output $@ $<

expected.tex: sample.md first-line-indent.lua
	$(PANDOC) -s --lua-filter first-line-indent.lua --output $@ $<
