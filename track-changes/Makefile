DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc
.PHONY: test clean

## PENDING: ensure that LaTeX output can be compiled to PDF.
test: sample.md test-track-changes.sh sample.pdf
	@$(PANDOC) -t markdown --wrap=preserve \
	        --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_accept.markdown
	@$(PANDOC) -t markdown --wrap=preserve --track-changes=reject \
	        -M trackChanges:reject --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_reject.markdown
	@$(PANDOC) -t html --wrap=preserve --track-changes=all \
	        -M trackChanges:all --lua-filter=track-changes.lua sample.md | \
	    $(DIFF) - expected_draft.html
	@$(PANDOC) -M trackChanges:all --track-changes=all --wrap=preserve \
	        --to=latex --lua-filter=track-changes.lua \
	        --standalone sample.md | \
	    sh test-track-changes.sh
	@rm sample.pdf

sample.pdf: sample.md track-changes.lua
	@$(PANDOC) -M trackChanges:all --track-changes=all \
	        --lua-filter=track-changes.lua \
	        --output $@ $<

clean:
	rm sample.pdf || true
