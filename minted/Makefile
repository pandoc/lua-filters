.PHONY: all
all: sample_beamer.pdf sample_latex.pdf sample.html

pandoc_inputs := sample.md

sample_beamer.tex: $(pandoc_inputs)
	pandoc -s -t beamer --lua-filter=minted.lua $^ > $@

sample_beamer.pdf: sample_beamer.tex
	latexmk -pdf -shell-escape -jobname=sample_beamer sample_beamer

sample_latex.tex: $(pandoc_inputs)
	pandoc -s -t latex --lua-filter=minted.lua $^ > $@

sample_latex.pdf: sample_latex.tex
	latexmk -pdf -shell-escape -jobname=sample_latex sample_latex

sample.html: $(pandoc_inputs)
	pandoc -s -t html5 --lua-filter=minted.lua $^ > $@


.PHONY: clean
clean:
	latexmk -c sample_beamer >/dev/null 2>&1
	@# latexmk does not clean all beamer files
	rm -f sample_beamer.{nav,snm,vrb}
	rm -rf _minted-sample_beamer/
	latexmk -c sample_latex >/dev/null 2>&1
	rm -rf _minted-sample_latex/

realclean: clean
	rm -f sample_beamer.{tex,pdf}
	rm -f sample_latex.{tex,pdf}
	rm -f sample.html

.PHONY: test lint
lint:
	flake8 --max-line-length=80 run_minted_tests.py background_color.py

test:
	@./run_minted_tests.py
