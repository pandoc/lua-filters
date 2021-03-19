DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: latex html

latex: sample.md expected_filtered.tex expected_unfiltered.tex bib-place.lua
	@pandoc -s --citeproc --to latex --template template $< \
		| $(DIFF) expected_unfiltered.tex -
	@pandoc -s --citeproc --lua-filter bib-place.lua --to=latex \
		--template template $< | $(DIFF) expected_filtered.tex -

html: sample.md expected_filtered.html expected_unfiltered.html
	@pandoc -s --citeproc --to=html --template template $< \
		| $(DIFF) expected_unfiltered.html -
	@pandoc -s --citeproc --lua-filter bib-place.lua --to=html \
		--template template $< | $(DIFF) expected_filtered.html -

expected_filtered.html : sample.md bib-place.lua
	@pandoc -s --citeproc --lua-filter bib-place.lua \
	--output expected_filtered.html \
	--template template $< \

expected_filtered.tex : sample.md bib-place.lua
	@pandoc -s --citeproc --lua-filter bib-place.lua \
	--output expected_filtered.tex \
	--template template $<

expected_unfiltered.html : sample.md bib-place.lua
	@pandoc -s --citeproc --output expected_unfiltered.html \
	--template template $<

expected_unfiltered.tex : sample.md bib-place.lua
	@pandoc -s --citeproc --output expected_unfiltered.tex \
	--template template $<
