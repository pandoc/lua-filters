FILTERS=$(wildcard $(shell find * -type d | grep -v '[/\\]'))
LUA_FILTERS_TEST_IMAGE = pandoc/lua-filters-test

.PHONY: test docker-test docker-test-image

test:
	bash runtests.sh $(FILTERS)

docker-test:
	docker run --rm --volume "$(PWD):/data" $(LUA_FILTERS_TEST_IMAGE) \
	    make test

docker-test-image: .tools/Dockerfile
	docker build --tag $(LUA_FILTERS_TEST_IMAGE) --file $< .
