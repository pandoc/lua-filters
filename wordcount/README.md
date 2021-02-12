# wordcount

This filter counts the words and characters in the body of a document
(omitting metadata like titles and abstracts), including words in
code. It should be more accurate than `wc -w` or `wc -m` run directly
on a Markdown document, since `wc` will also count markup characters,
like the `#` in front of an ATX header, or tags in HTML documents.

To run it, `pandoc --lua-filter wordcount.lua myfile.md`.
The word count will be printed to stdout.

If you want to process the document as well as printing the word count
set the variable `wordcount` to `process` (or `process-anyway` or `convert`).
This works only in conjunction with the standalone document option (`-s`).
This can be done through the command line:

```
pandoc -s -L wordcount.lua -M wordcount=process sample.md -o output.html
```

Or the document's metadata block:

```
---
title: My Long Book
wordcount: process-anyway
---
```

