#!/usr/bin/env bash

# produces the readme in various formats
# the filter processVerbatim.lua add the verbatim examples as real markdown

# assumes Pandoc and a full Latex install
# langsci-gb4e.sty is made available here

# note that there are various errors in the output
# they show current limitations

# basic formats

for format in html docx epub
do
	pandoc ../readme.md -t markdown -L processVerbatim.lua -s | \
	pandoc -t $format -o readme.$format -L ../pandoc-ling.lua -s -N --toc
done

# various latex variants, both tex and pdf

for package in linguex gb4e langsci-gb4e
do
	pandoc ../readme.md -t markdown -L processVerbatim.lua -s | \
	pandoc -t latex -o readme_$package.tex -L ../pandoc-ling.lua -s -N --toc \
	--metadata latexPackage="$package"

	pandoc ../readme.md -t markdown -L processVerbatim.lua -s | \
	pandoc -o readme_$package.pdf -L ../pandoc-ling.lua -N --toc \
	--metadata latexPackage="$package" --pdf-engine=xelatex
done

# special settings for expex, errors with xelatex and chapternumbers

pandoc ../readme.md -t markdown -L processVerbatim.lua -s | \
pandoc -t latex -o readme_expex.tex -L ../pandoc-ling.lua -s -N --toc \
--metadata latexPackage="expex" --metadata addChapterNumber="false"

pandoc ../readme.md -t markdown -L processVerbatim.lua -s | \
pandoc -o readme_expex.pdf -L ../pandoc-ling.lua -N --toc \
--metadata latexPackage="expex" --pdf-engine=pdflatex --metadata addChapterNumber="false"
