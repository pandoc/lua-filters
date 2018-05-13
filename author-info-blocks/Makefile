test: sample.md author-info-blocks.lua
	@pandoc --lua-filter=author-info-blocks.lua --standalone --to=native $< \
	    | diff -u - expected.native

expected.native: sample.md author-info-blocks.lua
	pandoc --lua-filter=author-info-blocks.lua --standalone --output $@ $<

.PHONY: test
