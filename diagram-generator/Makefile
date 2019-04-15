.PHONY: test
test: sample.html

sample.html: sample.md
	@pandoc --self-contained \
	    --lua-filter=diagram-generator.lua \
	    --metadata=activatePythonPath:"python3 --version" \
	    --metadata=pythonPath:"python3" \
	    --metadata=title:"README" \
	    --output=$@ $<

clean:
	rm -f sample.html
	rmdir tmp-latex || true
