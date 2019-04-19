DIFF ?= diff --strip-trailing-cr -u
LF	=	--lua-filter=short-captions.lua
F	=	-F pandoc-crossref

test:
	@pandoc $(LF) README.md -w latex | $(DIFF) expected-1.tex -

crossref:
	@echo testing short-captions.lua after  pandoc-crossref
	@pandoc $(F) $(LF) README.md -w latex | $(DIFF) expected-2.tex -
	@echo testing short-captions.lua before pandoc-crossref
	@pandoc $(LF) $(F) README.md -w latex | $(DIFF) expected-2.tex -

readme:
	@pandoc -s $(F) $(LF)  README.md -o README.pdf

latex:
	@pandoc -s $(F) $(LF)  README.md -o README.tex

