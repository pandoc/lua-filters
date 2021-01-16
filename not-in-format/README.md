---
title: "Not-in-format - Keep document parts out of selected output
  formats"
author: "Julien Dutant"
---

Not-in-format
=======

Keeps parts of a document out of selected output formats.

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Usage
-----

This Lua filter for Pandoc that keeps parts of a document out of selected outputs formats.

*Use case*. Sometimes a bit of markdown will convert well through Pandoc
to some formats not others. Say, you have a table that is reasonably
well converted to html and docx, but you want more control on the
LaTeX output. This filter allows you to:

* Enter the desired LaTeX table output as a [fenced block with a raw
  attribute](https://pandoc.org/MANUAL.html#extension-raw_attribute).
* Mark up the markdown table so that it is output only in formats other
  than LaTeX.

*Usage*. Mark up the part you want to keep out of some output format(s)
as a native Div with the attributes `not-in-format` and the names of the
format(s) in question:

```markdown
::: {.not-in-format .latex .beamer}

---------------------------
This table   is not kept
----------- ----------------
in formats    latex, beamer
----------------------------

:::
```

Use format names for [Pandoc's list of output formats](https://pandoc.org/MANUAL.html#option--to), which you can print out by running ```pandoc --list-output-formats```.

You would normally provide a raw equivalent for the part in question in
the format(s) in question, using Pandoc's [fenced blocks with a raw
attribute](https://pandoc.org/MANUAL.html#extension-raw_attribute):

```markdown
::: {.not-in-format .latex .beamer}

---------------------------
This table   is not kept
----------- ----------------
in formats    latex, beamer
----------------------------

:::

~~~{=latex}

begin{tabular}{|c|c|}
\toprule
This table & is not kept \\ \addlinespace
\midrule
\endhead
in formats & latex, beamer \\ \addlinespace
\bottomrule
\end{tabluar}

~~~
```

A fenced block with a raw attribute can only have one attribute, so you
need one for each format for which the markdown is left out. But Pandoc
will output the raw block in equivalent formats: a `latex` block will
be output in `latex` and `beamer`, a `html5` block in `html` and `epub3`
and so on. See [Pandoc's manual](https://pandoc.org/MANUAL.html#extension-raw_attribute).

Installation
------------

Copy `not-in-format.lua` in your document folder or in your pandoc data
dir path.

Contributing
------------

PRs welcome.
