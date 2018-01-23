.PHONY: test

test:
	@pandoc -s -t markdown --lua-filter=track-changes-final.lua sample.md | diff --strip-trailing-cr -u - expected_final.markdown
	@pandoc -s -t latex --lua-filter=track-changes-latex.lua sample.md | diff --strip-trailing-cr -u - expected_draft.tex
