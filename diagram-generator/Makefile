.PHONY: test
test: sample.html

sample.html: sample.md
	@pandoc --self-contained \
	    --lua-filter=diagram-generator.lua \
	    --metadata=pythonPath:"python3" \
	    --metadata=title:"README" \
	    --output=$@ $<

clean:
	rm -f sample.html
	rm -rf tmp-latex
