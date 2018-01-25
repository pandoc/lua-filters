.PHONY: test

test:
	@pandoc -s -t markdown --wrap=preserve --lua-filter=track-changes.lua sample.md | diff --strip-trailing-cr -u - expected_final.markdown
	@pandoc -s -t latex --wrap=preserve --track-changes=all --lua-filter=track-changes.lua sample.md | diff --strip-trailing-cr -u - expected_draft.tex
	@pandoc -s -t html --wrap=preserve --track-changes=all --lua-filter=track-changes.lua sample.md | diff --strip-trailing-cr -u - expected_draft.html
