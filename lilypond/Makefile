DIFF ?= diff --strip-trailing-cr -u

test-appoggiaturas:
	@{ pandoc --lua-filter=lilypond.lua appoggiaturas.md \
		| $(DIFF) appoggiaturas.expected -; } && \
	cmp beethoven.png beethoven.expected
