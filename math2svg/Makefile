DIFF ?= diff --strip-trailing-cr -u

test: sample.md math2svg.lua
	@pandoc \
		--mathml --lua-filter=math2svg.lua \
			-M math2svg_font='Gyre-Pagella' \
		--to=html sample.yaml $< \
	    | $(DIFF) expected.html -

expected: sample.md math2svg.lua
	pandoc \
		--mathml --lua-filter=math2svg.lua \
			-M math2svg_font='Gyre-Pagella' \
		--output=expected.html sample.yaml $<

.PHONY: test
