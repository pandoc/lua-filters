DIFF ?= diff --strip-trailing-cr -u

test: sample.md displaymath2svg.lua
	@pandoc --mathml --lua-filter=displaymath2svg.lua --to=html $< \
	    | $(DIFF) expected.html -

expected: sample.md displaymath2svg.lua
	pandoc --mathml --lua-filter=displaymath2svg.lua --output=expected.html $<

.PHONY: test
