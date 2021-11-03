DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: test-appoggiaturas test-oboe test-code

test-appoggiaturas:
	@{ $(PANDOC) --lua-filter=lilypond.lua -t native \
	          --extract-media=. appoggiaturas.md \
		| $(DIFF) appoggiaturas.native.expected -; } && \
	test -e beethoven.png

test-oboe:
	@{ $(PANDOC) --lua-filter=lilypond.lua -t native --extract-media=. oboe.md \
		| $(DIFF) oboe.native.expected -; } && \
	test -e oboe.png && \
	test -e b-flat.png

test-code:
	@$(PANDOC) --lua-filter=lilypond.lua -t native code.md \
		| $(DIFF) code.native.expected -

.PHONY: test test-appoggiaturas test-oboe test-code
