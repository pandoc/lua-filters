.POSIX:

BASE_DIR   := test
DATA_DIR   := $(BASE_DIR)/data
NORM_DIR   := $(BASE_DIR)/norms
UNIT_DIR   := $(BASE_DIR)/unit
TMP_DIR    := $(BASE_DIR)/tmp
SCRIPT_DIR := $(BASE_DIR)/scripts

HTTP_SERVER_PORT	?= 23120
SHELL				?= sh
RM 					?= rm -f
COLLECT_WARN_TESTS	:= find $(UNIT_DIR)/warn -type f -name '*.lua' \
	-exec basename \{\} \; | sed 's/.lua$$//' | sort

SIMPLE_UNIT_TESTS	:= test_core test_retrieval
UNIT_TESTS 			:= $(SIMPLE_UNIT_TESTS) test_get_input_directory test_warn
GENERATIVE_TESTS	:= test-keytype-easy-citekey \
	test-keytype-better-bibtex test-keytype-zotero-id \
	test-bibliography

test: prepare-tmpdir start-http-server \
	$(UNIT_TESTS) $(GENERATIVE_TESTS) \
	stop-http-server

prepare-tmpdir:
	mkdir -p $(TMP_DIR)
	$(RM) $(TMP_DIR)/*

start-http-server:
ifeq ('$(NO_HTTP_SERVER)', '')
	$(SHELL) test/scripts/httpdctl start "$(HTTP_SERVER_PORT)"
endif

stop-http-server:
ifeq ('$(NO_HTTP_SERVER)', '')
	$(SHELL) test/scripts/httpdctl stop
endif

$(SIMPLE_UNIT_TESTS): prepare-tmpdir
ifeq ('$(NO_HTTP_SERVER)', '')
	pandoc --lua-filter $(UNIT_DIR)/test.lua -o /dev/null \
		-M query-base-url=http://localhost:$(HTTP_SERVER_PORT) \
		-M tests=$@ /dev/null || \
		{ EX=$$?; sh test/scripts/httpdctl stop || :; exit "$$EX"; }
else
	pandoc --lua-filter $(UNIT_DIR)/test.lua -o /dev/null \
		-M tests=$@ /dev/null	
endif

test_get_input_directory:
	pandoc --lua-filter $(UNIT_DIR)/get_input_directory-pwd.lua </dev/null

test_warn: prepare-tmpdir
	for TEST in `$(COLLECT_WARN_TESTS)`; do \
		pandoc --lua-filter $(UNIT_DIR)/warn/$$TEST.lua -o /dev/null \
			/dev/null 2>$(TMP_DIR)/$$TEST.out; \
		cmp $(NORM_DIR)/warn/$$TEST.out $(TMP_DIR)/$$TEST.out; \
	done

$(GENERATIVE_TESTS): prepare-tmpdir
ifeq ('$(NO_HTTP_SERVER)', '')
	-pandoc --lua-filter $(SCRIPT_DIR)/pandoc-zotxt-test.lua \
		-F pandoc-citeproc -t plain -o $(TMP_DIR)/$@.txt \
		-M query-base-url=http://localhost:$(HTTP_SERVER_PORT) \
		$(DATA_DIR)/$@.md
	cmp $(TMP_DIR)/$@.txt $(NORM_DIR)/$@.txt || \
		{ EX=$$?; sh test/scripts/httpdctl stop || :; exit "$$EX"; }
else
	pandoc --lua-filter ./pandoc-zotxt.lua -F pandoc-citeproc -t plain \
		-o $(TMP_DIR)/$@.txt $(DATA_DIR)/$@.md
	cmp $(TMP_DIR)/$@.txt $(NORM_DIR)/$@.txt
endif
	
.PHONY: prepare-tmpdir start-http-server stop-http-server test \
	$(UNIT_TESTS) $(GENERATIVE_TESTS)

