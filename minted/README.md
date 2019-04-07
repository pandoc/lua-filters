# minted

This filter enables users to use the [`minted`][minted] package with the
`beamer` and `latex` writers.  Users may attach any desired `minted` specific
styling / attributes to their code-blocks (or via document metadata).  These
`minted` specific attributes will be _removed_ for any writers that are not
`beamer` or `latex`, since many of the `minted` options require using `latex`
specific syntax that can cause problems in other output formats.  For example,
if the `fontsize=\footnotesize` attribute were applied to a code block, an
`html` export would include `data-fontsize="\footnotesize"`, which may produce
errors or more commonly be entirely meaningless for non-latex writers.

The `minted` package will be used as a _replacement_ for the existing `pandoc`
inline code and code block elements.  Behind the scenes, `minted` builds on top
of the `fancyvrb` latex package, using [pygments][pygments] to perform the
highlighting.  The `minted` package contains _many_ options for customizing
output, users are encouraged to read / review section 5.3 of the
[minted documentation][minted_docs].  **This filter does not make any attempts
to validate arguments supplied to the `minted` package**.  Invalid / conflicting
arguments are a usage error.

**Contents**

- [Setup](#setup)
    - [LaTeX Preamble Configuration](#latex-preamble-configuration)
    - [PDF Compilation](#pdf-compilation)
- [Minted Filter Settings](#minted-filter-settings)
    - [Default Settings](#default-settings)
    - [All Metadata Settings](#all-metadata-settings)
        - [`no_default_autogobble`](#no_default_autogobble-boolean)
        - [`no_mintinline`](#no_mintinline-boolean)
        - [`default_block_language`](#default_block_language-string)
        - [`default_inline_language`](#default_inline_language-string)
        - [`block_attributes`](#block_attributes-list-of-strings)
        - [`inline_attributes`](#inline_attributes-list-of-strings)
- [Important Usage Notes](#important-usage-notes)
- [Bonus](#bonus)

# Setup

## LaTeX Preamble Configuration

Since this filter will emit `\mintline` commands for inline code, and
`\begin{minted} ... \end{minted}` environments for code blocks, you must ensure
that your document includes the `minted` package in the preamble of your
`beamer` or `latex` document.  The filter cannot accomplish this for you.

**Option 1**

Use the `header-includes` feature of `pandoc` (`-H` / `--include-in-header`).
This will be injected into the preamble section of your `beamer` or `latex`
document.  The bare minimum you need in this file is

```latex
\usepackage{minted}
```

However, there are many other things you can set here (related or unrelated to
this filter), and this is a good opportunity to perform some global setup on the
`minted` package.  Some examples:

```latex
\usepackage{minted}

% Set the `style=tango` attribute for all minted blocks.  Can still be overriden
% per block (e.g., you want to change just one).  Run `pygmentize -L` to see
% all available options.
\usemintedstyle{tango}

% Depending on which pygments style you choose, comments and preprocessor
% directives may be italic.  The `tango` style is one of these.  This disables
% all italics in the `minted` environment.
\AtBeginEnvironment{minted}{\let\itshape\relax}

% This disables italics for the `\mintinline` commands.
% Credit: https://tex.stackexchange.com/a/469702/113687
\usepackage{xpatch}
\xpatchcmd{\mintinline}{\begingroup}{\begingroup\let\itshape\relax}{}{}
```

The `minted` package has many options, see the
[minted documentation][minted_docs] for more information.  For example, see the
`bgcolor` option for the `minted` package.  In this "header-include" file would
be an excellent location to `\definecolor`s that you want to use with `bgcolor`.

**Option 1.5**

You can also set `header-includes` in the metadata of your document.  The above
example could be set as (noting the escaped backslashes):

```yaml
colorlinks: true
header-includes:
  # Include the minted package, set global style, define colors, etc.
  - "\\usepackage{minted}"
  - "\\usemintedstyle{tango}"
  # Prevent italics in the `minted` environment.
  - "\\AtBeginEnvironment{minted}{\\let\\itshape\\relax}"
  # Prevent italics in the `\mintinline` command.
  - "\\usepackage{xpatch}"
  - "`\\xpatchcmd{\\mintinline}{\\begingroup}{\\begingroup\\let\\itshape\\relax}{}{}`{=latex}"
```

Note on the last line calling `\xpatchcmd`, we escape the backslashes and
additionally force `pandoc` to treat this as `latex` code by making it an inline
`latex` code element.  See [pandoc issue 2139 (comment)][pandoc_issue_2139] for
more information.

Formally, you may want to apply the ``-"`\\raw_tex`{=latex}"`` trick to all
metadata to indicate it is `latex` specific code.  However, since `pandoc`
strips out any raw `latex` when converting to other writers, it isn't necessary.

**Option 2**

You can also create your own custom `beamer` or `latex` template to have much
finer control over what is / is not included in your document.  You may obtain
a copy of the template that `pandoc` uses by default by running
`pandoc -D beamer` or `pandoc -D latex` depending on your document type.

After you have modified the template to suit your needs (including at the very
least a `\usepackage{minted}`), specify your template file to `pandoc` using
the `--template <path/to/template/file>` command line argument.

## PDF Compilation

To compile a PDF, there are two things that the `minted` package requires be
available: an escaped shell to be able to run external commands (the
`-shell-escape` command line flag), and the ability to create and later read
auxiliary files (`minted` runs `pygmentize` for the highlighting).

At the time of writing this, only one of these is accessible using `pandoc`
directly.  One may pass `--pdf-engine-opt=-shell-escape` to forward the
`-shell-escape` flag to the latex engine being used.  Unfortunately, though,
the second component (related to temporary files being created) is not supported
by `pandoc`.  See [pandoc issue 4271][pandoc_issue_4271].

**However**, in reality this is an minor issue that can easily be worked around.
Instead of generating `md => pdf`, you just use `pandoc` to generate `md => tex`
and then compile `tex => pdf` yourself.  See the [sample Makefile](Makefile) for
examples of how to execute both stages.  **Furthermore**, you will notice a
significant advantage of managing the `pdf` compilation yourself: the generated
`minted` files are cached and unless you `make clean` (or remove them manually),
unchanged code listings will be reused.  That is, you will have faster
compilation times :slightly_smiling_face:

# Minted Filter Settings

Direct control over the settings of this filter are performed by setting
sub-keys of a `minted` metadata key for your document.

## Default Settings

By default, this filter

1. Transforms all inline `Code` elements to `\mintinline`.  This can be disabled
   globally by setting `no_mintinline: true`.

2. Transforms all `CodeBlock` elements to `\begin{minted} ... \end{minted}` raw
   latex code.  This cannot be disabled.

3. Both (1) and (2) default to the `"text"` pygments lexer, meaning that inline
   code or code blocks without a specific code class applied will receive no
   syntax highlighting.  This can be changed globally by setting
   `default_block_language: "lexer"` or `default_inline_language: "lexer"`.

4. All `CodeBlock` elements have the `autogobble` attribute applied to them,
   which informs `minted` to trim all common preceding whitespace.  This can be
   disabled globally by setting `no_default_autogobble: true`.  However, doing
   this is **strongly discouraged**.  Consider a code block nested underneath
   a list item.  Pandoc will (correctly) generate indented code, meaning you
   will need to manually inform `minted` to `gobble=indent` where `indent` is
   the number of spaces to trim.  Note that `pandoc` may not reproduce the same
   indentation level of the original document.

## All Metadata Settings

Each of the following are nested under the `minted` metadata key.

### `no_default_autogobble` (boolean)

By default this filter will always use `autogobble` with minted, which will
automatically trim common preceding whitespace.  This is important because
code blocks nested under a list or other block elements _will_ have common
preceding whitespace that you _will_ want trimmed.

### `no_mintinline` (boolean)

Globally prevent this filter from emitting `\mintinline` calls for inline
Code elements, emitting `\texttt` instead.  Possibly useful in saving
compile time for large documents that do not seek to have syntax
highlighting on inline code elements.

### `default_block_language` (string)

The default pygments lexer class to use for code blocks.  By default this
is `"text"`, meaning no syntax highlighting.  This is a fallback value, code
blocks that explicitly specify a lexer will not use it.

### `default_inline_language` (string)

Same as `default_block_language`, only for inline code (typed in single
backticks).  The default is also `"text"`, and changing is discouraged.

### `block_attributes` (list of strings)

Any default attributes to apply to _all_ code blocks.  These may be
overriden on a per-code-block basis.  See section 5.3 of the
[minted documentation][minted_docs] for available options.

### `inline_attributes` (list of strings)

Any default attributes to apply to _all_ inline code.  These may be
overriden on a per-code basis.  See section 5.3 of the
[minted documentation][minted_docs] for available options.

[minted_docs]: http://mirrors.ctan.org/macros/latex/contrib/minted/minted.pdf
[minted]: https://ctan.org/pkg/minted?lang=en
[pygments]: http://pygments.org/
[pandoc_issue_2139]: https://github.com/jgm/pandoc/issues/2139#issuecomment-310522113
[pandoc_issue_4271]: https://github.com/jgm/pandoc/issues/4721

# Important Usage Notes

Refer to the [`sample.md`](sample.md) file for some live examples of how to use
this filter.  If you execute `make` in this directory, `sample_beamer.pdf`,
`sample_latex.pdf`, and `sample.html` will all be generated to demonstrate the
filter in action.

`pandoc` allows you to specify additional attributes on either the closing
backtick of an inline code element, or after the third backtick of a fenced
code block.  This is done using `{curly braces}`, an example:

```md
`#include <type_traits>`{.cpp .showspaces style=bw}
```

or

    ```{.cpp .showspaces style=bw}
    #include <type_traits>
    ```

In order, these are

- `.cpp`: specify the language lexer class.
- `.showspaces`: a `minted` boolean attribute.
- `style=bw`: a `minted` attribute that takes an argument (`bw` is a pygments
  style, black-white, just an example).

There are two rules that must not be violated:

1. Any time you want to supply extra arguments to `minted` to a specific inline
   code or code block element, **the lexer class must always be first, and
   always be present**.

   This is a limitation of the implementation of this filter.

2. Observe the difference between specifying boolean attributes vs attributes
   that take an argument.  Boolean `minted` attributes **must** have a leading
   `.`, and `minted` attributes that take an argument **may not** have a leading
   `.`.

    - **Yes**: `{.cpp .showspaces}`, **No**: `{.cpp showspaces}`
    - **Yes**: `{.cpp style=bw}`, **No**: `{.cpp .style=bw}`

   If you violate this, then `pandoc` will likely not produce an actual inline
   `Code` or `CodeBlock` element, but instead something else (undefined).

Last, but not least, you will see that the `--no-highlight` flag is used in the
`Makefile` for the latex targets.  This is added in the spirit of the filter
being a "full replacement" for `pandoc` highlighting with `minted`.  This only
affects inline code elements that meet the following criteria:

1. The inline code element has a lexer, e.g., `{.cpp}`.
2. The inline code element can actually be parsed for that language by `pandoc`.

If these two conditions are met, and you do **not** specify `--no-highlight`,
the `pandoc` highlighting engine will take over.  Users are encouraged to build
the samples (`make` in this directory) and look at the end of the
`Special Characters are Supported` section.  If you remove `--no-highlight`,
`make realclean`, and then `make` again, you will see that the pandoc
highlighting engine will colorize the `auto foo = [](){};`.

Simply put: if you do not want any pandoc highlighting in your LaTeX, **make
sure you add `--no-highlight`** and it will not happen.

It is advantageous for this filter to rely on this behavior, because it means
that the filter does not need to worry about escaping special characters for
LaTeX -- `pandoc` will do that for us.  Inspect the generated `sample_*.tex`
files (near the end) to see the difference.  `--no-highlight` will produce
`\texttt` commands, but omitting this flag will result in some `\VERB` commands
from `pandoc`.

# Bonus

Included here is a simple python script to help you get the right color
definitions for `bgcolor` with minted.  Just run
[`background_color.py`](background_color.py) with a single argument that is the
name of the pygments style you want the `latex` background color definition for:

```console
$ ./background_color.py monokai
Options for monokai (choose *one*):

  (*) \definecolor{monokai_bg}{HTML}{272822}
  (*) \definecolor{monokai_bg}{RGB}{39,40,34}
  (*) \definecolor{monokai_bg}{rgb}{0.1529,0.1569,0.1333}
                   |--------/
                   |
                   +--> You can rename this too :)
```

See the contents of [`sample.md`](sample.md) (click on "View Raw" to see the
comments in the metadata section).  Notably, in order to use `\definecolor` you
should make sure that the `xcolor` package is actually included.  Comments in
the file explain the options.
