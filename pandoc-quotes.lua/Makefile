DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc
BASE_DIR := test
DATA_DIR := $(BASE_DIR)/docs
TMP_DIR  := $(BASE_DIR)/tmp
NORM_DIR := $(BASE_DIR)/norms

TESTS := test-simple test-lookup-simple test-lookup-void-country \
	test-lookup-mapping test-lookup-no-fallback

test: test-noop $(TESTS)

prepare-tmp:
	@mkdir -p test/tmp
	@rm -f test/tmp/*

test-noop: prepare-tmp
	@$(PANDOC) --lua-filter ./$(PANDOC)-quotes.lua -f markdown-smart -t html \
		-o $(TMP_DIR)/$@.out $(DATA_DIR)/$@.md
	@$(DIFF) $(TMP_DIR)/$@.out $(NORM_DIR)/$@.out

$(TESTS): prepare-tmp
	@$(PANDOC) --lua-filter ./$(PANDOC)-quotes.lua -t html \
		-o $(TMP_DIR)/$@.out $(DATA_DIR)/$@.md
	@$(DIFF) $(TMP_DIR)/$@.out $(NORM_DIR)/$@.out


.PHONY: prepare-tmp test $(TESTS)
