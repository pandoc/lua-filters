.PHONY: test

PANDOC_COMMAND = pandoc -L complex-paragraphs.lua -t native sample.md

test:
	TESTED_FORMAT=context $(PANDOC_COMMAND) -o tests/output.context \
		&& diff tests/output.context tests/expected.context
	TESTED_FORMAT=openxml $(PANDOC_COMMAND) -o tests/output.docx  \
		&& diff tests/output.docx tests/expected.docx
	TESTED_FORMAT=latex $(PANDOC_COMMAND) -o tests/output.latex \
		&& diff tests/output.latex tests/expected.latex \
	&& rm tests/output.*
