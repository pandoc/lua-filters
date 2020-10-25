DIFF ?= diff --strip-trailing-cr -u

test: sample.md include-code-files.lua
	@pandoc --lua-filter=include-code-files.lua --to=native $< \
	    | $(DIFF) expected.native -

expected.native: sample.md include-code-files.lua
	pandoc --lua-filter=include-code-files.lua --output $@ $<

.PHONY: test
