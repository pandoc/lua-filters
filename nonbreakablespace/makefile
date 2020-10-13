DIFF ?= diff --strip-trailing-cr -u

test:
	@pandoc --lua-filter=nonbreakablespace.lua sample.md | $(DIFF) expected.html -

.PHONY: test