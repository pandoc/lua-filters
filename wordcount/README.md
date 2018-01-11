# wordcount

This filter counts the words in the body of a document (omitting
metadata like titles and abstracts), including words in code.
It should be more accurate than `wc -w` run directly on a
Markdown document, since the latter will count markup
characters, like the `#` in front of an ATX header, or
tags in HTML documents, as words.

To run it, `pandoc --lua-filter wordcount.lua myfile.md`.
The word count will be printed to stdout.
