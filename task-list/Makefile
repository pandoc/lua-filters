.PHONY: test test_%

test: test_markdown test_html test_gfm test_org

test_%: expected.% task-list.lua sample.md
	@pandoc --lua-filter=task-list.lua sample.md -s -t $* | diff --strip-trailing-cr -u - $<

