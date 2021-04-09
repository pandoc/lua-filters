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

# Source code

``` {.include .source .bash}
// this will include simple bash files
shell1
shell2
```

# Appendix

More info goes here.

``` {.include shift-heading-level-by=1}
// headings in included documents are shifted down a level,
// a level 1 heading becomes level 2.
file-c.md
```
