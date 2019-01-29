---
title: Pandoc Minted Sample
# NOTE: If you want to use `\definecolor` commands in your `header-includes`
# section, setting `colorlinks: true` will `\usepackage{xcolor}` which is needed
# for `\definecolor`.  You can alternatively `\usepackage{xcolor}` explicitly in
# in the `header-includes` section if you do not want everything else that
# `colorlinks: true` will bring in.  See `pandoc -D latex` output to see
# everything that `colorlinks: true` will do _in addition_ to including xcolor.
colorlinks: true
header-includes:
  # Include the minted package, set global style, define colors, etc.
  - "\\usepackage{minted}"
  - "\\usemintedstyle{tango}"
  - "\\definecolor{tango_bg}{rgb}{0.9725,0.9725,0.9725}"
  - "\\definecolor{monokai_bg}{rgb}{0.1529,0.1569,0.1333}"
  # NOTE: comment out these last three and recompile to see the italics used
  # by default for the `tango` style.
  # Prevent italics in the `minted` environment.
  - "\\AtBeginEnvironment{minted}{\\let\\itshape\\relax}"
  # Prevent italics in the `\mintinline` command.
  - "\\usepackage{xpatch}"
  - "`\\xpatchcmd{\\mintinline}{\\begingroup}{\\begingroup\\let\\itshape\\relax}{}{}`{=latex}"
minted:
  block_attributes:
    - "bgcolor=tango_bg"
---

## Inline Code in Pandoc

- Raw inline code:

    ```md
    `#include <type_traits>`
    ```

  \vspace*{-3ex} produces: `#include <type_traits>`

- Apply just a lexer:

    ```md
    `#include <type_traits>`{.cpp}
    ```

    \vspace*{-3ex} produces: `#include <type_traits>`{.cpp}

- Change the background color and highlighting style:

    ```{.md fontsize=\scriptsize}
    <!-- Note: we defined monokai_bg in the metadata! -->
    `#include <type_traits>`{.cpp bgcolor=monokai_bg style=monokai}
    ```

    \vspace*{-3ex} produces:
    `#include <type_traits>`{.cpp bgcolor=monokai_bg style=monokai}

    - Must **always** include language (`.cpp` here) **first**, always!

## Inline Code Bypasses

- Want the regular teletype text?  Specify **both** the lexer class name and one
  additional class `.no_minted`.

    ```{.md}
    <!-- The "text lexer" -->
    `no minted`{.text .no_minted}
    ```

    \vspace*{-3ex} produces: `no mintinline`{.text .no_minted} vs `with mintinline`

    - Inspect generated code, the PDF output is indistinguishable.

- Alternatively, you can set `no_mintinline: true`{.yaml style=paraiso-light} to prevent the filter
  from emitting _any_ `\mintinline`{.latex} calls.
    - If you don't need syntax highlighting on your inline code elements, this may
      greatly improve compile times for large documents.


## Code Blocks

- Use the defaults, but still supply the lexer:

        ```bash
        echo "Hi there" # How are you?
        ```

    \vspace*{-3ex} produces

    ```bash
    echo "Hi there" # How are you?
    ```

    \vspace*{-3ex}

- As with inline code, you can change whatever you want:

        ```{.bash bgcolor=monokai_bg style=monokai}
        echo "Hi there" # How are you?
        ```

    \vspace*{-3ex} produces

    ```{.bash bgcolor=monokai_bg style=monokai}
    echo "Hi there" # How are you?
    ```

    \vspace*{-3ex}

    - Must **always** include language (`.bash` here) **first**, always!


## Special Characters are Supported

- Code blocks:

    ```md
    `~!@#$%^&*()-=_+[]}{|;':",.\/<>?
    ```

    \vspace*{-3ex}

- Inline code

    ``with mintinline `~!@#$%^&*()-=_+[]}{|;':",.\/<>?``

  Note: If you use almost all special characters *and* all alphanumeric
  characters in a single inline code fragment, minted may not be able to find a
  suitable delimiter to place around the \LaTeX\ inline command.

- Inline code with bypass

    ``no mintinline `~!@#$%^&*()-=_+[]}{|;':",.\/<>?``{.text .no_minted}

- Specific lexer with mintinline: `auto foo = [](){};`{.cpp}
- Without mintinline: `auto foo = [](){};`{.cpp .no_minted}
    - Output color depends on `--no-highlight` flag for `pandoc`.
