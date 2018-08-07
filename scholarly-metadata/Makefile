test: sample.md scholarly-metadata.lua
	@pandoc --lua-filter=scholarly-metadata.lua --standalone --to=markdown $< \
	    | diff -u expected.md -

expected.md: sample.md scholarly-metadata.lua
	pandoc --lua-filter=scholarly-metadata.lua --standalone --output $@ $<

.PHONY: test
