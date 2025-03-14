DIFF := diff --ignore-all-space --ignore-blank-lines -u
PANDOC ?= pandoc

.PHONY: test
test:
	@$(PANDOC) --lua-filter=commonmark-code-blocks.lua -f commonmark -t html sample.md | \
		$(DIFF) expected.html -

.PHONY: all
all: test

