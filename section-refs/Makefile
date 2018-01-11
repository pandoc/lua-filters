PANDOC_VERSION = $(shell pandoc --version | head -n1 | sed 's/^pandoc //g')
PANDOC_MAJOR_VERSION = $(shell echo $(PANDOC_VERSION) | awk -F'.' '{print $$1}')
PANDOC_MINOR_VERSION = $(shell echo $(PANDOC_VERSION) | awk -F'.' '{print $$2}')

OPTIONS_test_default := -t native \
	-M bibliography=bibliography.bib \
	-F pandoc-citeproc \
	--lua-filter=section-refs.lua

OPTIONS_test_no_citeproc := -t native \
	-M bibliography=bibliography.bib \
	--lua-filter=section-refs.lua

OPTIONS_test_refs_name := -t native \
	-M bibliography=bibliography.bib \
	-M reference-section-title="Works Cited" \
	-F pandoc-citeproc \
	--lua-filter=section-refs.lua

OPTIONS_test_section_level := -t native \
	-M bibliography=bibliography.bib \
	-M reference-section-title="Works Cited" \
	-M section-refs-level=2\
	-F pandoc-citeproc \
	--lua-filter=section-refs.lua

.PHONY: test
test: test_default test_no_citeproc test_refs_name test_section_level
	@echo "testing for pandoc >= 2.1"

test_%: expected_%.native sample.md bibliography.bib
	@pandoc sample.md $(OPTIONS_$@) | diff -u - $<
