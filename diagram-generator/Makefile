.PHONY: test
test: clean sample.html

sample.html: sample.md diagram-generator.lua
	@pandoc --self-contained \
	    --lua-filter=diagram-generator.lua \
	    --metadata=pythonPath:"python3" \
	    --metadata=title:"README" \
	    --output=$@ $<

clean:
	@rm -f sample.html
	@rm -rf tmp-latex
