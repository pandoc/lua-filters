---
title: "Longtable-to-xtab - switch LaTeX table outputs from longtable to xtab"
author: "Julien Dutant"
---

Longtable-to-xtab
=======

Convert Pandoc's LaTeX table output from `longtable` to `xtab`.

v1.0. Copyright: © 2021 Julien Dutant <julien.dutant@kcl.ac.uk>
License:  MIT - see LICENSE file for details.

Introduction
------------

By default Pandoc outputs uses the LaTeX package `longtable` to format
tables in LaTeX. However `longtable` environments cannot be used in a two column document or in a multiple columns environements (`multicol`).
In those contexts one should use the `supertabular` or `xtab` packages -
preferably `xtab`, which is based on `supertabular` and improves it.

This filter converts the LaTeX output of Pandoc for tables from
`longtable` to `xtab` codes. It does so by implementing a [suggestion of
Bustel](https://github.com/jgm/pandoc/issues/1023#issuecomment-656769330):
redefine the longtable environment in LaTeX itself.

Usage
-----

### Installation

Copy `longtable-to-xtab.lua` in your document folder or in your pandoc data
dir path.

### Usage

Add `-L longtable-to-xtab.lua` to your Pandoc command line, or add
`filter: longtable-to-xtab.lua` to a document's metadata block.

Details
----

### Dependencies

Unlike `longtable`, the `xtab` and `supertabular` LaTeX packages are not
included in the core list of LaTeX packages. In Linux Debian distributions
they are included in the package `texlive-latex-extra`.

### The duplicate headers issue and how the filter solves it

If a table has both headers and a caption, Pandoc generates a first header
(caption and headers) and main header (headers only). See the code below for an illustration. If we simply turned the table into an `xtabular` and erase the `\endfirsthead` and `\endhead` commands we would get two header rows.

```latex
\begin{longtable}[]{@{}
  >{\centering\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.17}}
  >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.11}}
  >{\raggedleft\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.22}}
  >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.36}}@{}}
\caption{Here's the \emph{caption}. It, too, may span multiple
lines.}\tabularnewline
\toprule
Centered Header & Default Aligned & Right Aligned & Left
Aligned\footnote{Footnote in a table.} \\ \addlinespace
\midrule
\endfirsthead
\toprule
Centered Header & Default Aligned & Right Aligned & Left
Aligned{} \\ \addlinespace
\midrule
\endhead
First & row & 12.0 & Example of a row that spans multiple
lines. \\ \addlinespace
Second & row & 5.0 & Here's another one. Note the blank line between
rows. \\ \addlinespace
\bottomrule
\end{longtable}

```

Possible solutions:

1. Use `\iffalse ...\endif` to turn off LaTeX on the main header. **This is
  the solution adopted here.** It's a bit of a hack.

  Limitation: from `xtab`'s point of view the remaining first header row is a normal row. Not ideal if the table does span several pages.

2. strip the markdown table of its headers, and add the headers as
  `\tablefirstheader` (includes footnote) and `\tableheader` (*footnotes stripped and other unique identifiers need to be stripped from the
  repeat header*). See below Pandoc code without headers (the
  `\toprule` should be redefined to nothing).

  ```latex
  \begin{longtable}[]{@{}
    >{\centering\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.17}}
    >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.11}}
    >{\raggedleft\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.22}}
    >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.36}}@{}}
  \toprule
  \endhead
  First & row & 12.0 & Example of a row that spans multiple
  lines. \\ \addlinespace
  Second & row & 5.0 & Here's another one. Note the blank line between
  rows. \\ \addlinespace
  \bottomrule
  ```

  and see below the ideal `xtab` code for the first and main headers:

  ```latex
  \tablecaption{Here's the \emph{caption}. It, too, may span multiple
  lines.}
  \tablefirsthead{\toprule
  Centered Header & Default Aligned & Right Aligned & Left
  Aligned\footnote{Footnote in a table.} \\ \midrule}
  \tablehead{\toprule Centered Header & Default Aligned & Right Aligned & Left Aligned \\ \midrule}
  \begin{center}
  \begin{xtabular}[]{@{}
    >{\centering\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.17}}
    >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.11}}
    >{\raggedleft\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.22}}
    >{\raggedright\arraybackslash}p{(\columnwidth - 6\tabcolsep) * \real{0.36}}@{}}
  First & row & 12.0 & Example of a row that spans multiple
  lines. \\ \addlinespace
  Second & row & 5.0 & Here's another one. Note the blank line between
  rows. \\ \addlinespace
  \bottomrule
  \end{xtabular}
  \end{center}
  ```

Contributing
------------

PRs welcome.

