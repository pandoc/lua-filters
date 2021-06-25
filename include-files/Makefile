DIFF ?= diff --strip-trailing-cr -u

.EXPORT_ALL_VARIABLES:

SUBDIR_NAME=subdir


test: sample.md file-a.md file-b.md file-c.md include-files.lua
	@pandoc --lua-filter=include-files.lua -M subdir-name="subdir" --to=native $< \
	    | $(DIFF) expected.native -
	@pandoc --lua-filter=include-files.lua -M subdir-name="subdir" -M include-auto --to=native $< \
	    | $(DIFF) expected-auto.native -

expected.native: sample.md file-a.md file-b.md file-c.md include-files.lua
	pandoc --lua-filter=include-files.lua -M subdir-name="subdir" --output $@ $<

expected-auto.native: sample.md file-a.md file-b.md file-c.md include-files.lua
	pandoc --lua-filter=include-files.lua -M subdir-name="subdir" -M include-auto --output $@ $<

.PHONY: test
