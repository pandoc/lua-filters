---
title: "Column Div - leverage Pandoc native divs to make columns
 an other things"
author: "Christophe Agathon"
---

Column Div
=======

Columns and other things with Pandoc's markdown

This Lua filter for Pandoc improves Pandoc's Div usage.Especially
fenced divs witten in Pandocs markdown.

v1.0. Copyright: © 2021 Christophe Agathon
  <christophe.agathon@gmail.com>
License:  MIT - see LICENSE file for details.

Introduction
------------
Pandoc fenced divs can be very powerful allowing providing, in
theory many document formating possibilities. Unfortunately, plain
Panfoc processing doesn't make full adventage of it and discards
some formating in HTML outputs and most of it in Latex outputs.

Multiple columns in document are only partialy accessible in
Beamer (not plain Latex) and HTML outputs.

As a result, it's not possible to render fancy multi columns
PDF document from markdown sources.

The main purpose of this filter is to make it possible and give
similar formating features for both Latex/PDF and HTML outputs.

Usage
-----

### Basic usage

Copy `column-div.lua` in your document folder or in your pandoc
data directory (details in
[Pandoc's manual](https://pandoc.org/MANUAL.html#option--lua-filter)).
Run it on your document with a `--luafilter` option:

```bash
pandoc --luafilter column-div.lua SOURCE.md -o OUTPUT.pdf

```

or specify it in a defaults file (details in
[Pandoc's manual](https://pandoc.org/MANUAL.html#option--defaults)).

This will generate consistent HTML, Latex and PDF outputs from
Pandoc markdown files.

### Formating the document

Everything is done with Pandoc's fenced divs with class names and
attributes. The attributes are similar to those from Latex and/or
HTML styling.

#### Multiple balanced columns
For Latex and PDF output, you will need to call the multicol
package. This can be done un the YAML header.

**Example:**

```markdown
---
header-includes:
    - |
      ```{=latex}
      \usepackage{multicol}

      ```
---

Some regular text

:::: {.multicols column-count="2"}
Some text formatted on 2 columns
::::
```

* Latex output is done with `multicols` environment.
* HTML output uses `style="column-count: 2"` on a div block.

#### Unbalanced columns

No specific Latex package are needed. We use Nested Pandoc divs in
the same way that columns and column environments are used in
Beamer/Latex.

**Example:**

```markdown

:::::::: {.columns}
:::: {.column width="20%" valign="c"}
Some text or image using 20% of the page width.
::::
:::: {.column width="80%" valign="c"}
Some text or image using 80% of the page with.
::::
::::::::
```

* Beamer/Latex output is based on columns and column environments
* Plain Latex (and PDF) rendering use minipage environments
* HTML rendering is not affected by this filter since Pandoc do it
well already (based on divs with `width` attributes).

#### Other usages

HTML : you can already create divs with whatever class names youl
like and style them with `style=" … "` attributes. This is
proccessed by Pandoc and as nothing to do with this filter.

This filter allows to do the same in Latex (and PDF).
The class name is used as the environment name and a
`data-latex=" … "` attribute allows you to pass options and
parameters to the `\begin` instruction.

To Do
-----

Others multi column features could be implemented as column
spacing, rules, etc.

Since Pandoc does a very good job with the `width` styling
attribute to implement variable column width, it could easily
support HTML balanced column via the `column-count` attribute.

Contributing
------------

PRs welcome.

