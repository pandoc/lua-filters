DIFF ?= diff --strip-trailing-cr -u
.PHONY: test clean

## PENDING: ensure that LaTeX output can be compiled to PDF.
test: sample.md test-track-changes.sh sample.pdf
	@pandoc -t markdown --wrap=preserve \
	        --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_accept.markdown
	@pandoc -t markdown --wrap=preserve --track-changes=reject \
	        -M trackChanges:reject --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_reject.markdown
	@pandoc -s -t html --wrap=preserve --track-changes=all \
	        -M trackChanges:all --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_draft.html
	@pandoc -M trackChanges:all --track-changes=all --wrap=preserve \
	        --to=latex --lua-filter=track-changes.lua \
	        --standalone sample.md | \
	    sh test-track-changes.sh
	@rm sample.pdf

sample.pdf: sample.md track-changes.lua
	@pandoc -M trackChanges:all --track-changes=all \
	        --lua-filter=track-changes.lua \
	        --output $@ $<

clean:
	rm sample.pdf || true
