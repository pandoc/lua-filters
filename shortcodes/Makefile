DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= FOO="bar" pandoc

test:
	@$(PANDOC) --lua-filter=shortcodes.lua --output=test/output.html test/sample.md
	@$(DIFF) test/expected.html test/output.html
	@rm -f test/output.html
	
expected: test/sample.md shortcodes.lua
	$(PANDOC) test/sample.md --lua-filter=shortcodes.lua --output test/expected.html

	
.PHONY: test

