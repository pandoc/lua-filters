DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

.PHONY: test

test: test_html test_latex

test_html: sample.md expected.html not-in-format.lua
	@$(PANDOC) --lua-filter not-in-format.lua --to=html --wrap=none $< \
		| $(DIFF) expected.html -

test_latex: sample.md expected.tex not-in-format.lua
	@$(PANDOC) --lua-filter not-in-format.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md not-in-format.lua
	$(PANDOC) --lua-filter not-in-format.lua --wrap=none --output $@ $<

expected.tex: sample.md not-in-format.lua
	$(PANDOC) --lua-filter not-in-format.lua --output $@ $<
