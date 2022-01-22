---
title: "tables-vrules - Pandoc filter to add vertical rules to tables"
author: "Christophe Agathon"
---

Tables VRules
=======

Add vertical rules to tables.

v1.0. Copyright: © 2021 Christophe Agathon
  <christophe.agathon@gmail.com>
License:  MIT - see LICENSE file for details.

Introduction
------------

Since pandoc has a strong policy against vertical rules in tables, peole have been looking for solutions to get those, especially when rendering PDF files via Latex. 

For more information you can refer to :

* This Pandoc issue [https://github.com/jgm/pandoc/issues/922](https://github.com/jgm/pandoc/issues/922)
* This discussion on StackExchange [https://tex.stackexchange.com/questions/595615/how-can-i-reformat-a-table-using-markdown-pandoc-pdf/596005](https://tex.stackexchange.com/questions/595615/how-can-i-reformat-a-table-using-markdown-pandoc-pdf/596005)

marjinshraagen proposed a solution based on a patch of `\LT@array` in Latex. It used to work pretty well. It doesn't anymore for Multiline Tables and Pipes Tables since Pandoc changed the Latex code it generates for those kind of tables. Don't know exactly when it changed but sometime between Pandoc version 2.9.2.1 and version 2.16.

Since patching in Latex is tricky and I am not a Latex guru, I didn't manage to make it work again, so I made this filter which change the call to `longtable` to add vertical rules in a more "natural" whay.


Usage
-----

### Formating the document

Simply use on of the table synthax allowed by Pandoc (details in
[Pandoc's manual](https://pandoc.org/MANUAL.html#tables).


### Rendering the document

Copy `tables-vrules.lua` in your document folder or in your pandoc
data directory (details in
[Pandoc's manual](https://pandoc.org/MANUAL.html#option--lua-filter)).
Run it on your document with a `--luafilter` option:

```bash
pandoc --luafilter tables-vrules.lua SOURCE.md -o OUTPUT.pdf

```

or specify it in a defaults file (details in
[Pandoc's manual](https://pandoc.org/MANUAL.html#option--defaults)).

This will generate Tables with vertical rules in Latex and PDF documents from Pandoc markdown source files.

### Limitations

This filter is active only for Latex and PDF output.

Vertical rules in HTML documents should be handled via css styling.

Contributing
------------

PRs welcome.

