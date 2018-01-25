.PHONY: test

test:
	@pandoc -s -t markdown --wrap=preserve --lua-filter=track-changes-final.lua sample.md | diff --strip-trailing-cr -u - expected_final.markdown
	@pandoc -s -t latex --wrap=preserve --lua-filter=track-changes-latex.lua sample.md | diff --strip-trailing-cr -u - expected_draft.tex
	@pandoc -s -t html --wrap=preserve --lua-filter=track-changes-html.lua sample.md | diff --strip-trailing-cr -u - expected_draft.html
