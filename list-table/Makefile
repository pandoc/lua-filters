DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc
CMD = $(PANDOC) --lua-filter list-table.lua --to=html sample.md

test:
	@$(CMD) | $(DIFF) expected.html -

update:
	$(CMD) > expected.html

.PHONY: test update
