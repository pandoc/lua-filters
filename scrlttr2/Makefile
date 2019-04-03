test: sample.md scrlttr2.lua sample.pdf
	sh expected-strings.sh
	rm sample.pdf

%.pdf: %.md scrlttr2.lua
	pandoc --lua-filter=scrlttr2.lua --output=$@ $<

.PHONY: test
