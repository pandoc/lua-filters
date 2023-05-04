DIFF ?= diff --strip-trailing-cr -u

.EXPORT_ALL_VARIABLES:

BANANA = eat a banana


test: sample.md
	@pandoc --lua-filter=codeblock-var-replace.lua --to=native $< \
	    | $(DIFF) expected.native -

expected.native: sample.md
	pandoc --lua-filter=codeblock-var-replace.lua --output $@ $<

expected.json: sample.md
	pandoc --lua-filter=codeblock-var-replace.lua -t json --output $@ $<


.PHONY: test
