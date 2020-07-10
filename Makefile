FILTERS=$(wildcard $(shell find * -type d | grep -v '[/\\]'))
FILTER_FILES=$(shell find * -name "*.lua" -type f)
LUA_FILTERS_TEST_IMAGE = tarleb/lua-filters-test

.PHONY: test show-args docker-test docker-test-image archive

test:
	bash runtests.sh $(FILTERS)

archive: .build/lua-filters.tar.gz

show-vars:
	@printf "FILTERS: %s\n" $(FILTERS)
	@printf "FILTER_FILES: %s\n" $(FILTER_FILES)

docker-test:
	docker run \
	       --rm \
	       --volume "$(PWD):/data" \
		     --entrypoint /usr/bin/make \
	       $(LUA_FILTERS_TEST_IMAGE)

docker-test-image: .tools/Dockerfile
	docker build --tag $(LUA_FILTERS_TEST_IMAGE) --file $< .

# Build a single collection of Lua filters
.PHONY: collection
collection: .build/lua-filters

.build/lua-filters: $(FILTER_FILES)
	mkdir -p .build/lua-filters
	cp -a $(FILTER_FILES) .build/lua-filters
	cp -a LICENSE .build/lua-filters
	@printf "Filters collected in '%s'\n" "$@"

.build/lua-filters.tar.gz: .build/lua-filters
	tar -czf $@ -C .build lua-filters
	@printf "Archive written to '%s'\n" "$@"

clean:
	rm -rf .build
	$(foreach f,$(FILTERS),make -C $(f) clean;)
