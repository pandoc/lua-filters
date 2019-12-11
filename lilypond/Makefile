DIFF ?= diff --strip-trailing-cr -u

test: test-appoggiaturas test-oboe

test-appoggiaturas:
	@{ pandoc --lua-filter=lilypond.lua -t html appoggiaturas.md \
		| $(DIFF) appoggiaturas.html.expected -; } && \
	test -e beethoven.png

test-oboe:
	@{ pandoc --lua-filter=lilypond.lua -t html oboe.md \
		| $(DIFF) oboe.html.expected -; } && \
	test -e oboe.png && \
	test -e b-flat.png


.PHONY: test test-appoggiaturas test-oboe
