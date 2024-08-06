---
title: "Column Div - leverage Pandoc native divs to make columns
 and other things"
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

My guidelines are :

1) Use Pandoc divs like many already have proposed for uneven and even columns
2) Same functionalities and rendering in HTML and Latex+PDF
3) Mess the least possible with plain Pandoc processing which is quite OK already for HTML (miss only column-count for even columning).
4) Allow users to use unknown Latex environments from exotic packages if they wish, provided they include them in the preamble.


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
attributes. The attributes are similar to those from HTML styling and/or
Latex.

#### Multiple even columns
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

#### Uneven columns

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

For HTML outputs, you already can create divs with whatever class names you
like and style them with `style=" … "` attributes. This is
processed by Pandoc and has nothing to do with this filter.

This filter allows to do the same in Latex (and PDF).
You can create whatever environment you need. The environment name is the
class name given to the fenced div. In case of multiple class names, the 
first one is used. Other are ignored but allowed to help you to maintain 
a single markdown source for PDF and HTML outputs.
The `data-latex=" … "` attribute allows you to pass options and
parameters to the `\begin` environment instruction.

To Do
-----

Others multi column features could be implemented as column
spacing, rules, etc.

Since Pandoc does a very good job with the `width` styling
attribute to implement variable column width, it could easily
support HTML even column via the `column-count` attribute.

Contributing
------------

PRs welcome.

