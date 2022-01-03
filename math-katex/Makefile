DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md math-katex.lua expected.html
	@$(PANDOC) \
		--lua-filter=math-katex.lua \
			-M math_katex_bin='/usr/bin/katex' \
		--to=html --output=output.html \
		sample.md 
		@$(DIFF) expected.html output.html
		@rm -f output.tex

expected: sample.md math-katex.lua
	$(PANDOC) \
		--lua-filter=math-katex.lua \
			-M math_katex_bin='/usr/bin/katex' \
			-M math_katex_no_throw_on_error=false \
		--output=expected.html $<

.PHONY: test
