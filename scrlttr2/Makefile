PANDOC ?= pandoc

test: sample.md scrlttr2.lua sample.pdf
	@$(PANDOC) --to=latex --lua-filter=scrlttr2.lua -s sample.md | \
	    sh expected-strings.sh
	@rm sample.pdf

%.pdf: %.md scrlttr2.lua
	@$(PANDOC) --lua-filter=scrlttr2.lua --output=$@ $<

.PHONY: test
