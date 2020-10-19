[![travis build
status](https://img.shields.io/travis/pandoc/lua-filters/master.svg?label=travis+build)](https://travis-ci.org/pandoc/lua-filters)

# Lua Filters

This repository collects Lua filters for pandoc.

To learn about Lua filters, see the
[documentation](http://pandoc.org/lua-filters.html).

Summary
-------
1. [**abstract-to-meta**](https://github.com/pandoc/lua-filters/tree/master/abstract-to-meta): This moves a document's abstract from the main text into the metadata. Metadata elements usually allow for finer placement control in the final output, but writing body text is easier and more natural.
1. [**author-info-blocks**](https://github.com/pandoc/lua-filters/tree/master/author-info-blocks):  This filter adds author-related header blocks usually included in scholarly articles, such as a list of author affiliations, correspondence information, and on notes equal contributors.
1. [**bibexport**](https://github.com/pandoc/lua-filters/tree/master/bibexport):  Export all cited references into a single bibtex file. This is most useful when writing collaboratively while using a large, private bibtex collection. Using the bibexport filter allows to create a reduced bibtex file suitable for sharing with collaborators.
1. [**cito**](https://github.com/pandoc/lua-filters/tree/master/cito):  This filter extracts optional CiTO (Citation Typing Ontology) information from citations and stores the information in the document's metadata. The extracted info is intended to be used in combination with other filters, templates, or custom writers.
1. [**diagram-generator**](https://github.com/pandoc/lua-filters/tree/master/diagram-generator):  This Lua filter is used to create images with or without captions from code blocks. Currently PlantUML, Graphviz, TikZ and Python can be processed.
1. [**include-files**](https://github.com/pandoc/lua-filters/tree/master/include-files):  Filter to include other files in the document.
1. [**latex-hyphen**](https://github.com/pandoc/lua-filters/tree/master/latex-hyphen): Filter that replaces intra-word hyphens with the raw LaTeX expression "= for improved hyphenation.
1. [**lilypond**](https://github.com/pandoc/lua-filters/tree/master/lilypond):  This filter renders LilyPond inline code and code blocks into embedded images of musical notation.
1. [**lua-debug-example**](https://github.com/pandoc/lua-filters/tree/master/lua-debug-example): Example of how to debug Pandoc Lua filters using Zerobrane Studio.
1. [**minted**](https://github.com/pandoc/lua-filters/tree/master/minted): This filter enables users to use the `minted` package with the beamer and latex writers. 
1. [**multiple-bibliographies**](https://github.com/pandoc/lua-filters/tree/master/multiple-bibliographies): This filter allows to create multiple bibliographies using `citeproc`. The content of each bibliography is controlled via YAML values and the file in which a bibliographic entry is specified.
1. [**pagebreak**](https://github.com/pandoc/lua-filters/tree/master/pagebreak): This filter converts paragraps containing only the LaTeX `\newpage` or `\pagebreak` command into appropriate pagebreak markup for other formats. 
1. [**pandoc-quotes**](https://github.com/pandoc/lua-filters/tree/master/pandoc-quotes.lua): A filter for Pandoc that replaces non-typographic quotation marks with typographic ones for languages other than American English.
1. [**revealjs-codeblock**](https://github.com/pandoc/lua-filters/tree/master/revealjs-codeblock): This filter overwrites the code block HTML for `revealjs` output to enable the code presenting features of reveal.js.
1. [**scholarly-metadata**](https://github.com/pandoc/lua-filters/tree/master/scholarly-metadata): The filter turns metadata entries for authors and their affiliations into a canonical form. This allows users to conveniently declare document authors and their affiliations, while making it possible to rely on default object metadata structures when using the data in other filters or when accessing the data from custom templates.
1. [**scrlttr2**](https://github.com/pandoc/lua-filters/tree/master/scrlttr2): This filter allows to write DIN 5008 letter using the scrlttr2 LaTeX document class from KOMA script. It converts metadata to the appropriate KOMA variables and allows using the default LaTeX template shipped with pandoc.
1. [**section-refs**](https://github.com/pandoc/lua-filters/tree/master/section-refs): This filter allows the user to put bibliographies at the end of each section, containing only those references in the section.
1. [**short-captions**](https://github.com/pandoc/lua-filters/tree/master/short-captions): For LaTeX output, this filter uses the attribute `short-caption` for figures so that the attribute value appears in the List of Figures, if one is desired.
1. [**spellcheck**](https://github.com/pandoc/lua-filters/tree/master/spellcheck): This filter checks the spelling of words in the body of the document (omitting metadata). The external program aspell is used for the checking, and must be present in the path.
1. [**table-short-captions**](https://github.com/pandoc/lua-filters/tree/master/table-short-captions): For LaTeX output, this filter enables use of the attribute `short-caption` for tables. The attribute value will appear in the List of Tables.
1. [**track-changes**](https://github.com/pandoc/lua-filters/tree/master/track-changes): This filter allows you to use `--track-changes` in multiple formats.
1. [**wordcount**](https://github.com/pandoc/lua-filters/tree/master/wordcount): This filter counts the words and characters in the body of a document (omitting metadata like titles and abstracts), including words in code. It should be more accurate than wc -w or wc -m run directly on a Markdown document.


Requirements
------------

Filters are tested against the latest pandoc version.  There is
no guarantee that filters will work with older versions, but
many do.

Some filters depend on external programs, which must be installed
separately.  Refer to the filters' README for detailed
requirements.

Structure
---------

Each filter goes in its own subdirectory.  Each subdirectory contains:

- the filter itself (e.g. `wordcount.lua`)
- a `README.md` describing the use of the filter
- a `Makefile` with a `test` target to test the filter
- some data files used for the tests, which may also serve
  as examples
  
Contributing
------------

PRs for new filters are welcome, provided they conform to these
guidelines. Lua code should ideally follow the Olivine Labs [Lua
style guide].

[Lua style guide]: https://github.com/Olivine-Labs/lua-style-guide

