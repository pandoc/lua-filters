DIFF ?= diff --strip-trailing-cr -u

test: sample.md math2svg.lua
	@pandoc --mathml --lua-filter=math2svg.lua --to=html $< \
	    | $(DIFF) expected.html -

expected: sample.md math2svg.lua
	pandoc --mathml --lua-filter=math2svg.lua --output=expected.html $<

.PHONY: test
