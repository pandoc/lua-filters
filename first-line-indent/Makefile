DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: sample.md expected.html \
	sample_head-inc_1.md expected_hi_1.html expected_hi_1.tex \
	sample_head-inc_2.md expected_hi_2.html expected_hi_2.tex \
	sample_head-inc_3.md expected_hi_3.html expected_hi_3.tex \
	first-line-indent.lua
	@pandoc -s --lua-filter first-line-indent.lua --to=html sample.md \
		| $(DIFF) expected.html -
	@pandoc -s --lua-filter first-line-indent.lua --to=latex sample.md \
		| $(DIFF) expected.tex -
	@pandoc -s --lua-filter first-line-indent.lua --to=html sample_head-inc_1.md \
		| $(DIFF) expected_hi_1.html -
	@pandoc -s --lua-filter first-line-indent.lua --to=latex sample_head-inc_1.md \
		| $(DIFF) expected_hi_1.tex -
	@pandoc -s --lua-filter first-line-indent.lua --to=html sample_head-inc_2.md \
		| $(DIFF) expected_hi_2.html -
	@pandoc -s --lua-filter first-line-indent.lua --to=latex sample_head-inc_2.md \
		| $(DIFF) expected_hi_2.tex -
	@pandoc -s --lua-filter first-line-indent.lua --to=html sample_head-inc_3.md \
		| $(DIFF) expected_hi_3.html -
	@pandoc -s --lua-filter first-line-indent.lua --to=latex sample_head-inc_3.md \
		| $(DIFF) expected_hi_3.tex -

expected.html: sample.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected.tex: sample.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_1.html: sample_head-inc_1.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_1.tex: sample_head-inc_1.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_2.html: sample_head-inc_2.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_2.tex: sample_head-inc_2.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_3.html: sample_head-inc_3.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

expected_hi_3.tex: sample_head-inc_3.md first-line-indent.lua
	pandoc -s --lua-filter first-line-indent.lua --output $@ $<

