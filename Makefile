FILTERS=$(wildcard $(shell find * -type d | grep -v '[/\\]'))
.PHONY: test

test:
	bash runtests.sh $(FILTERS)
