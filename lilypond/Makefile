DIFF ?= diff --strip-trailing-cr -u

test: test-appoggiaturas test-oboe

test-appoggiaturas:
	@{ pandoc --lua-filter=lilypond.lua -t html appoggiaturas.md \
		| $(DIFF) appoggiaturas.html.expected -; } && \
	cmp beethoven.png beethoven.png.expected

test-oboe:
	@{ pandoc --lua-filter=lilypond.lua -t html oboe.md \
		| $(DIFF) oboe.html.expected -; } && \
	cmp oboe.png oboe.png.expected && \
	cmp b-flat.png b-flat.png.expected

.PHONY: test test-appoggiaturas test-oboe
