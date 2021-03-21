DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: test_latex

test_html: sample.md expected.html first-line-indent.lua
	@pandoc --lua-filter first-line-indent.lua --to=html $< \
		| $(DIFF) expected.html -

test_latex: sample.md expected.tex first-line-indent.lua
	@pandoc --lua-filter first-line-indent.lua --to=latex $< \
		| $(DIFF) expected.tex -

expected.html: sample.md first-line-indent.lua
	pandoc --lua-filter first-line-indent.lua --output $@ $<

expected.tex: sample.md first-line-indent.lua
	pandoc --lua-filter first-line-indent.lua --output $@ $<
