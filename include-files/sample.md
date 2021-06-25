---
author: me
title: Thesis
---

# Section 1

Thanks everyone!

``` {.include}
// file-a has just a paragraph
file-a.md
// file-b contains a header
file-b.md
```

# Different format

``` {.include format=org shift-heading-level-by=1}
// org-mode file
file-d.org
```

# Recursive transclusion

``` {.include}
// this will also include file-a.md
file-f.md
```

# Subdirectories

``` {.include}
// file-g.md includes an image and source code. The relative
// path used in file-g.md will be prefixed with subdir in the
// final document.
subdir/file-g.md
```

# Include/exclude if format

The next document should be included in formats `native, html, latex`.

```{.include include-if-format=native;html;latex}
subdir/file-h.md
```

The next document should not be included in formats `native, commonmark`.

```{.include exclude-if-format=native;commonmark}
subdir/file-i.md
```

# Meta and env var replacement

```{.include .var-replace}
// Replace meta data variable in path
${meta:subdir-name}/file-h.md
```

```{.include .var-replace}
// Replace envrionment variable in path
${env:SUBDIR_NAME}/file-h.md
```

# Raw include

```{.include raw=true format=latex}
subdir/file-h-latex.md
```

# Appendix

More info goes here.

``` {.include shift-heading-level-by=1}
// headings in included documents are shifted down a level,
// a level 1 heading becomes level 2.
file-c.md
```
