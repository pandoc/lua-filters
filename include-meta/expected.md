---
author:
- Jill Doe
- Frank van Lua
bibliography:
- my-references.bib
- project-references.bib
- document-specific-references.bib
header-includes:
- |
  ```{=tex}
  \usepackage[section]{placeins}
  ```
- "`\\setbeamertemplate{footline}`{=tex}\\[page number\\]"
institute: Markdown Lab at ACME University
lang: en
logo: logo-project.pdf
logo-width: 10cm
test_property: from_sample_doc
test_property_bool: false
title: My document
titlepage: false
titlepage-rule-color: 05519E
titlepage-rule-height: 15
titlepage-text-color: 050505
---

```{=tex}
\usepackage[section]{placeins}
```

`\setbeamertemplate{footline}`{=tex}\[page number\]

# My document

This is a simple sample.

The default author is added to the list.

![Image caption](image.png)
