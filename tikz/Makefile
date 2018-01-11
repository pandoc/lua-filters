test:
	@-rm *.png
	@pandoc --lua-filter=tikz.lua sample.md | diff -u - expected.html
	@ls 726a98dafc8c6f5cb06687af468d72e7f2336f2f.png >/dev/null
