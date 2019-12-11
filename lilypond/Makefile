DIFF ?= diff --strip-trailing-cr -u

test-appoggiaturas:
	@{ pandoc --lua-filter=lilypond.lua appoggiaturas.md \
		| $(DIFF) appoggiaturas.html.expected -; } && \
	cmp beethoven.png beethoven.png.expected

test-oboe:
	@{ pandoc --lua-filter=lilypond.lua oboe.md \
		| $(DIFF) oboe.html.expected -; } && \
	cmp oboe.png oboe.png.expected && \
	cmp b-flat.png b-flat.png.expected

.PHONY: test-appoggiaturas test-oboe
