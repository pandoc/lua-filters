DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc
LF	=	--lua-filter=short-captions.lua
F	=	-F pandoc-crossref

test:
	@$(PANDOC) $(LF) README.md -w latex | $(DIFF) expected-1.tex -

crossref:
	@echo testing short-captions.lua after  pandoc-crossref
	@$(PANDOC) $(F) $(LF) README.md -w latex | $(DIFF) expected-2.tex -
	@echo testing short-captions.lua before pandoc-crossref
	@$(PANDOC) $(LF) $(F) README.md -w latex | $(DIFF) expected-2.tex -

readme:
	@$(PANDOC) -s $(F) $(LF)  README.md -o README.pdf

latex:
	@$(PANDOC) -s $(F) $(LF)  README.md -o README.tex
