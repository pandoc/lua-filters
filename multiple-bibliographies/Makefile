test: sample.md multiple-bibliographies.lua
	@pandoc --lua-filter=multiple-bibliographies.lua \
	        --standalone --to=native $< 2>/dev/null \
	    | diff -u - expected.native

.PHONY: test
