.PHONY: all
all: sample_beamer.pdf sample_latex.pdf sample.html

# NOTE: `pandoc_inputs` can have multiple filenames if you want to send `pandoc`
# more than one input file at once.  In the commands for the targets that depend
# on `pandoc_inputs` you will see a pattern `$^ > $@`.  It's less magic than it
# seems, but useful to point out if you have not seen these before.  They are
# called "Automatic Variables", and more documentation can be found here:
#
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
#
# So by depending on $(pandoc_inputs) and using $^ as the input files to
# `pandoc`, $^ will expand to all filenames in `pandoc_inputs` and the target
# will re-run when the timestamp of _any_ file listed in `pandoc_inputs` is
# updated.  By redirecting the output to $@, it will send the `pandoc` output to
# the target name.  In the examples below, $@ expands to either
# `sample_beamer.tex`, `sample_latex.tex`, or `sample.html` (depending on the
# target name).
#
# TL;DR: You should be able to copy-paste the commands below and just rename the
# target names to match whatever output filenames you want.
pandoc_inputs := sample.md

# Sample beamer presentation.
sample_beamer.tex: $(pandoc_inputs)
	pandoc -s -t beamer --no-highlight --lua-filter=minted.lua $^ > $@

sample_beamer.pdf: sample_beamer.tex
	latexmk -pdf -shell-escape -jobname=sample_beamer sample_beamer

# Sample latex document.
sample_latex.tex: $(pandoc_inputs)
	pandoc -s -t latex --no-highlight --lua-filter=minted.lua $^ > $@

sample_latex.pdf: sample_latex.tex
	latexmk -pdf -shell-escape -jobname=sample_latex sample_latex

# Sample html5 document.
sample.html: $(pandoc_inputs)
	pandoc -s -t html5 --lua-filter=minted.lua $^ > $@

# ---

.PHONY: clean realclean
clean:
	@# latexmk errors if no auxiliary files exist to cleanup.  Using `|| true`
	@# just makes it so that the subsequent commands will also execute.
	latexmk -c sample_beamer >/dev/null 2>&1 || true
	@# latexmk does not clean all beamer files
	rm -f sample_beamer.{nav,snm,vrb}
	rm -rf _minted-sample_beamer/
	latexmk -c sample_latex >/dev/null 2>&1 || true
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
