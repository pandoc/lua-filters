---
title: "Bib-place"
author: "Julien Dutant"
---

Bib-place
=======

Control the placement of a `citeproc`-generated bibliography
via Pandoc templates. Only works with a single-bibliography
document.

Introduction
------------

In Pandoc templates the main text is contained in the variable
`$body$`. Suppose you want your document template to add something
just below the body, such as the author's name and affiliation:

```
$body$

$for(author)$$author$$endfor$
$if(institute)$
$for(institute)$$institute$$endfor$
$endif$

```

When using `citeproc` to generate a bibliography you will not get
the desired result, because `citeproc`-generated bibliographies
are inserted at the end of the `$body$`` variable. The template
above will print the author's name and institute after the
bibliography.

This filter takes the `citeproc` bibliography out of `$body$` and
places it in a `$referencesblock$` variable instead.

Usage
----

Call the filter at the command line or in a defaults file (see Pandoc's
manual for detail). **Important**: the filter must be called after *citeproc*. From the command line:

```
pandoc -s --citeproc -L bib-place.lua sample.md -t html

pandoc -s --citeproc --lua-filter bib-place.lua sample.md -t html
```

In a default file:

```
filters:
- citeproc
- bib-place.lua
```

In you custom Pandoc template you can then place the references block with the `referencesblock` variable:

```
$body$

$for(author)$$author$$endfor$
$if(institute)$
$for(institute)$$institute$$endfor$
$endif$

$if(referencesblock)$$referencesblock$$endif$
```

Notes
-----

The template can be agnostic on which bibliography engine your run. If you process the document with other bibliography engines (natbib, biblatex) the filter will leave them untouched and you can place them by moving the
`\printbibliography` commands in the template.

If you use the filter with the default pandoc templates or with a template
that does not use `$referencesblock$` your bibliography will not be printed.
