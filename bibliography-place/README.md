---
title: "Bibliography-place"
author: "Julien Dutant"
---

Bibliography place
=======

Control the placement of a `citeproc`-generated bibliography
via Pandoc templates.

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

Call the filter from the command line or the defaults file. *It must be called
after citeproc*.

Place references with the `$referencesblock` variable:

```
$body$

$for(author)$$author$$endfor$
$if(institute)$
$for(institute)$$institute$$endfor$
$endif$

$if(referencesblock)$$referencesblock$$endif$
```

Warnings and troubleshooting
----------------------------

The filter must be called after *citeproc*.

If you process the document with another or no bibliography engine, the
reference sections will simply be erased.

If you use the filter with the default pandoc templates or with a template
that does not use `$referencesblock$` your bibliography will not be printed.

