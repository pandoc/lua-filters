DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test: sample.md file-a.md file-b.md file-c.md include-files.lua
	@$(PANDOC) --lua-filter=include-files.lua --to=native $< \
	    | $(DIFF) expected.native -
	@$(PANDOC) --lua-filter=include-files.lua -M include-auto --to=native $< \
	    | $(DIFF) expected-auto.native -

expected.native: sample.md file-a.md file-b.md file-c.md include-files.lua
	$(PANDOC) --lua-filter=include-files.lua --output $@ $<

expected-auto.native: sample.md file-a.md file-b.md file-c.md include-files.lua
	$(PANDOC) --lua-filter=include-files.lua -M include-auto --output $@ $<

.PHONY: test
