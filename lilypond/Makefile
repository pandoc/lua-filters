DIFF ?= diff --strip-trailing-cr -u

test: test-appoggiaturas test-oboe test-code

test-appoggiaturas:
	@{ pandoc --lua-filter=lilypond.lua -t native \
	          --extract-media=. appoggiaturas.md \
		| $(DIFF) appoggiaturas.native.expected -; } && \
	test -e beethoven.png

test-oboe:
	@{ pandoc --lua-filter=lilypond.lua -t native --extract-media=. oboe.md \
		| $(DIFF) oboe.native.expected -; } && \
	test -e oboe.png && \
	test -e b-flat.png

test-code:
	@pandoc --lua-filter=lilypond.lua -t native code.md \
		| $(DIFF) code.native.expected -

.PHONY: test test-appoggiaturas test-oboe test-code
