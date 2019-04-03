test: sample.md scrlttr2.lua
	sh expected-strings.sh

%.pdf: %.md scrlttr2.lua
	pandoc --lua-filter=scrlttr2.lua --output=$@ $<

.PHONY: test
