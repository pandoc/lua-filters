.PHONY: test clean

## PENDING: ensure that LaTeX output can be compiled to PDF.
test: sample.md test-track-changes.sh
	@pandoc -t markdown --wrap=preserve \
	        --lua-filter=track-changes.lua sample.md | \
	    diff --strip-trailing-cr -u - expected_accept.markdown
	@pandoc -t markdown --wrap=preserve --track-changes=reject \
	        -M trackChanges:reject --lua-filter=track-changes.lua sample.md | \
	    diff --strip-trailing-cr -u - expected_reject.markdown
	@pandoc -s -t html --wrap=preserve --track-changes=all \
	        -M trackChanges:all --lua-filter=track-changes.lua sample.md | \
	    diff --strip-trailing-cr -u - expected_draft.html
	@sh test-track-changes.sh

sample.pdf: sample.md track-changes.lua
	@pandoc -M trackChanges:all --track-changes=all \
	        --lua-filter=track-changes.lua \
	        --pdf-engine=xelatex \
	        --output $@ $<

clean:
	rm sample.pdf || true
