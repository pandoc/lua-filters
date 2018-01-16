test: sample.md scrlttr2.lua
	@pandoc --lua-filter=scrlttr2.lua -s --to=latex $< | diff -u - expected.latex

%.pdf: %.md
	pandoc --lua-filter=scrlttr2.lua --output $@ $<

.PHONY: test
