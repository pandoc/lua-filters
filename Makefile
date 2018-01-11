FILTERS=$(wildcard $(shell find * -type d))
.PHONY: test

test:
	bash runtests.sh $(FILTERS)
