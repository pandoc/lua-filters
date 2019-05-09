BASE_DIR := test
DATA_DIR := $(BASE_DIR)/data
NORM_DIR := $(BASE_DIR)/norms
TMP_DIR  := $(BASE_DIR)/tmp
UNIT_DIR := $(BASE_DIR)/unit_tests

KEYTYPE_TEST := test-keytype-easy-citekey \
	test-keytype-better-bibtex test-keytype-zotero-id

test: test-units test-keytype-easy-citekey test-bibliography 

test-units: test-units-main test-warn test-is-path-absolute \
	test-get-input-directory test-update-bibliography

test-better-bibtex: test-get-source-better-bibtex test-keytype-better-bibtex

all-tests: test test-better-bibtex test-keytype-zotero-id

prepare-tmp:
	mkdir -p $(TMP_DIR)
	rm -f $(TMP_DIR)/*

test-units-main: prepare-tmp
	pandoc --lua-filter $(UNIT_DIR)/main.lua /dev/null

test-warn: prepare-tmp
	for TEST in $(shell find $(UNIT_DIR)/warn -name '*.lua' \
		-exec basename \{\} \; | sed 's/.lua$$//' | sort); do \
		pandoc --lua-filter $(UNIT_DIR)/warn/$$TEST.lua /dev/null \
			2>$(TMP_DIR)/$$TEST.out; \
		cmp $(NORM_DIR)/warn/$$TEST.out $(TMP_DIR)/$$TEST.out; \
	done

test-is-path-absolute: prepare-tmp
	pandoc --lua-filter $(UNIT_DIR)/is_path_absolute.lua /dev/null

test-get-input-directory:
	pandoc --lua-filter $(UNIT_DIR)/get_input_directory/pwd.lua </dev/null
	pandoc --lua-filter $(UNIT_DIR)/get_input_directory/simple.lua \
		-o /dev/null $(DATA_DIR)/test-keytype-easy-citekey.md

test-update-bibliography: prepare-tmp
	pandoc --lua-filter $(UNIT_DIR)/update_bibliography.lua /dev/null \
		2>$(TMP_DIR)/update_bibliography.out
	cmp $(NORM_DIR)/update_bibliography.out $(TMP_DIR)/update_bibliography.out

test-get-source-better-bibtex:
	pandoc --lua-filter $(UNIT_DIR)/get_source-better-bibtex.lua /dev/null

$(KEYTYPE_TEST): prepare-tmp
	pandoc --lua-filter ./pandoc-zotxt.lua -F pandoc-citeproc -t plain \
		-o $(TMP_DIR)/$@.txt $(DATA_DIR)/$@.md
	cmp $(TMP_DIR)/$@.txt $(NORM_DIR)/$@.txt

test-bibliography: prepare-tmp
	pandoc --lua-filter ./pandoc-zotxt.lua -F pandoc-citeproc -t plain \
		-o $(TMP_DIR)/test-bibliography.txt $(DATA_DIR)/test-bibliography.md
	cmp $(TMP_DIR)/test-bibliography.txt $(NORM_DIR)/test-bibliography.txt
	test -e $(TMP_DIR)/test-bibliography.json
	pandoc --lua-filter ./pandoc-zotxt.lua -F pandoc-citeproc -t plain \
		-o $(TMP_DIR)/test-bibliography.txt $(DATA_DIR)/test-bibliography.md
	cmp $(TMP_DIR)/test-bibliography.txt $(NORM_DIR)/test-bibliography.txt
	
.PHONY: prepare-tmp \
	test-units test-units-main test-warn test-is-path-absolute \
	test-get-input-directory test-update-bibliography \
	test test-easy-citekey test-bibliography \
	test-better-bibtex test-get-source-better-bibtex \
	test-keytype-better-bibtex \
	all-tests test-zotero-id

