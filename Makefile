FILTERS=$(wildcard filters/*)
.PHONY: test

test:
	bash runtests.sh $(FILTERS)
