---
title: "Bibliography-place"
author: "Julien Dutant"
---

Bibliography place
=======

**WORK IN PROGRESS**

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

Place references with the `$referencesblock` variable:

```
$body$

$for(author)$$author$$endfor$
$if(institute)$
$for(institute)$$institute$$endfor$
$endif$

$if(referencesblock)$$referencesblock$$endif$
```

