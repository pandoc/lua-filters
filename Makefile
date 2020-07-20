FILTERS=$(wildcard $(shell find * -type d | grep -v '[/\\]'))
FILTER_FILES=$(shell find * -name "*.lua" -type f)
LUA_FILTERS_TEST_IMAGE = tarleb/lua-filters-test

.PHONY: test show-args docker-test docker-test-image archive

test: ## Runs all tests (to run specific test : make test FILTERS=target-filter-name)
	bash runtests.sh $(FILTERS)

archive: .build/lua-filters.tar.gz

show-vars: ## Displays vars used in this makefile
	@printf "FILTERS: %s\n" $(FILTERS)
	@printf "FILTER_FILES: %s\n" $(FILTER_FILES)

docker-test: ## Runs tests with docker (to run specific test : make docker-test FILTERS=target-filter-name)
	docker run \
	       --rm -it \
	       --volume "$(PWD):/data" \
	       --entrypoint /usr/bin/make \
	       $(LUA_FILTERS_TEST_IMAGE) FILTERS="${FILTERS}"

docker-test-image: .tools/Dockerfile ## Builds docker image for tests
	docker build --tag $(LUA_FILTERS_TEST_IMAGE) --file $< .

.PHONY: collection
collection: .build/lua-filters ## Builds a single collection of Lua filters

.build/lua-filters: $(FILTER_FILES)
	mkdir -p .build/lua-filters
	cp -a $(FILTER_FILES) .build/lua-filters
	cp -a LICENSE .build/lua-filters
	@printf "Filters collected in '%s'\n" "$@"

.build/lua-filters.tar.gz: .build/lua-filters
	tar -czf $@ -C .build lua-filters
	@printf "Archive written to '%s'\n" "$@"

clean: ## Cleans all folders
	rm -rf .build
	$(foreach f,$(FILTERS),make -C $(f) clean;)

help: ## Prints this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' ${MAKEFILE_LIST} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
