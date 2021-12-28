DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md math2svg.lua
	@$(PANDOC) \
		--mathml --lua-filter=math2svg.lua \
			-M math2svg_font='Gyre-Pagella' \
		--wrap=none \
		--to=html sample.yaml $< \
	    | $(DIFF) expected.html -

expected: sample.md math2svg.lua
	$(PANDOC) \
		--mathml --lua-filter=math2svg.lua \
			-M math2svg_tex2svg='/usr/local/bin/tex2svg' \
			-M math2svg_font='Gyre-Pagella' \
		--wrap=none \
		--output=expected.html sample.yaml $<

.PHONY: test
