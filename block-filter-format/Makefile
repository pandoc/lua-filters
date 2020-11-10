DIFF ?= diff --strip-trailing-cr -u

test: sample.md
	@pandoc --lua-filter=block-filter-format.lua --to=native $< \
	    | $(DIFF) expected.native -
	@pandoc --lua-filter=block-filter-format.lua -M block-filter-format-attrs --to=native $< \
	    | $(DIFF) expected-attrs.native -
	@pandoc --lua-filter=block-filter-format.lua --to=json $< \
	    | $(DIFF) expected.json -

expected.native: sample.md
	pandoc -f markdown+link_attributes --lua-filter=block-filter-format.lua --output $@ $<

expected-attrs.native: sample.md
	pandoc -f markdown+link_attributes --lua-filter=block-filter-format.lua -M block-filter-format-attrs --output $@ $<

expected.json: sample.md
	pandoc -f markdown+link_attributes --lua-filter=block-filter-format.lua --to=json --output $@ $<

parsed-ast.json: sample.md
	pandoc -f markdown+link_attributes --to=json --output $@ $<

.PHONY: test
