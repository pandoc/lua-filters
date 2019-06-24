DIFF = diff --strip-trailing-cr --ignore-all-space

test:
	@pandoc --lua-filter=sections.lua sample.md | $(DIFF) sample.html -
	@pandoc --lua-filter=sections.lua nested.md | $(DIFF) nested.html -

.PHONY: test
