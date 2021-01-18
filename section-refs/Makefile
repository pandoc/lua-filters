DIFF ?= diff --strip-trailing-cr -u

OPTIONS_test_default := -t native \
	-M bibliography=bibliography.bib \
	--citeproc \
	--lua-filter=section-refs.lua

OPTIONS_test_no_citeproc := -t native \
	--lua-filter=section-refs.lua

OPTIONS_test_refs_name := -t native \
	-M bibliography=bibliography.bib \
	-M reference-section-title="Works Cited" \
	--lua-filter=section-refs.lua

OPTIONS_test_section_level := -t native \
	-M bibliography=bibliography.bib \
	-M reference-section-title="Works Cited" \
	-M section-refs-level=2\
	--lua-filter=section-refs.lua

.PHONY: test
test: test_default test_no_citeproc test_refs_name test_section_level

test_%: expected_%.native sample.md bibliography.bib
	@pandoc sample.md $(OPTIONS_$@) | $(DIFF) $< -
