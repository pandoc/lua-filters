DIFF ?= diff --strip-trailing-cr -u

test: sample.md file-a.md file-b.md file-c.md shell1 shell2 include-files.lua
	@pandoc --lua-filter=include-files.lua --to=native $< \
	    | $(DIFF) expected.native -
	@pandoc --lua-filter=include-files.lua -M include-auto --to=native $< \
	    | $(DIFF) expected-auto.native -

expected.native: sample.md file-a.md file-b.md file-c.md shell1 shell2 include-files.lua
	pandoc --lua-filter=include-files.lua --output $@ $<

expected-auto.native: sample.md file-a.md file-b.md file-c.md include-files.lua
	pandoc --lua-filter=include-files.lua --output $@ $<

.PHONY: test
