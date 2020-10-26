# math2svg


## Description

This [Lua filter][pandoc.lua-filters] for [Pandoc][pandoc] converts
[LaTeX math][latex.math] to [MathJax][mathjax] generated
[scalable vector graphics (SVG)][svg] for insertion into the output document
in a standalone manner. 
SVG output is in any of the [available MathJax fonts][mathjax.fonts].

This is useful when a CSS paged media engine (such as [Prince XML][prince])
cannot process complex JavaScript as required by MathJax.
See: <https://www.print-css.rocks> for information about CSS paged media,
a [W3C standard][w3c]

No Internet connection is required when generating or viewing SVG formulas,
resulting in both absolute privacy and offline, standalone robustness.


## Requirements

First, use the package manager of your operating system to install `pandoc`,
`nodejs` and `npm`. `brew` and `choco` are recommended package mangers for
respectively macOS and Windows. See: <https://pandoc.org/installing.html>

```bash
$ sudo apt install pandoc nodejs npm
$ sudo dnf install pandoc nodejs npm
$ sudo yum install pandoc nodejs npm
$ brew install pandoc nodejs npm
> choco install pandoc nodejs npm
```

Then, by means of node's package manager `npm`, install the `mathjax-node-cli`
package. This package comes with the `tex2svg` executable.
Leave out the `sudo` on Windows.

```bash
$ sudo npm install --global mathjax-node-cli
> npm install --global mathjax-node-cli
```


## Usage

To be used as a [Pandoc Lua filter][pandoc.lua-filters].
[MathML][mathml] should be set as a fallback with
the `--mathml` argument.

```bash
pandoc --mathml --filter='math2svg.lua'
```

The math2svg filter is entirely configurable over
[`--metadata` key value pairs](pandoc.metadata).
Nine configuration keys are available with sensible default values.
Hence, depending on your system and intentions, not all keys are necessarily
required.

|key|default value|
|:--|:-----------:|
|`math2svg_tex2svg`|`''`|
|`math2svg_display2svg`|`true`|
|`math2svg_inline2svg`|`false`|
|`math2svg_speech`|`false`|
|`math2svg_linebreaks`|`true`|
|`math2svg_font`|`'TeX'`|
|`math2svg_ex`|`6`|
|`math2svg_width`|`100`|
|`math2svg_extensions`|`''`|


### Key value `math2svg_tex2svg`
This string key value is only required when, on your system, the path to the
`tex2svg` executable of the `mathjax-node-cli` package is not present in the
`$PATH` environment variable.

The full path to `tex2svg` can be found with the following command on \*nix,
respectively Windows:

```bash
$ which -a tex2svg
> where tex2svg
```

### Key values `math2svg_display2svg` and `math2svg_inline2svg`
These boolean key values specify whether display math, respectively inline math,
should be converted to [SVG][svg] by the filter.
The defaults convert display math to SVG, whereas inline math falls back to
[MathML][mathml] when `--mathml` was specified at `pandoc` evocation.
These defaults offer the following benefits:

- MathML output gets generated much faster than SVG output.
- Moreover, MathML is well suited for inline math as line heights are kept
  small.


### Key value `math2svg_speech`
This boolean key value controls whether textual annotations for speech
generation are added to SVG formula. The default is `false`.

### Key value `math2svg_linebreaks`
This boolean key value automatic switches automatic line breaking.
The default is `true`.


### Key value `math2svg_font`
This string key value allows to specify a [MathJax font][mathjax.fonts]
different from the default `'TeX'` font.
The string should correspond to the local directory name of the font in the
`mathjax-node-cli` installation directory.
For example, the key value string for the font in
`/usr/local/lib/node_modules/mathjax-node-cli/node_modules/mathjax/fonts/HTML-CSS/Gyre-Pagella/`
would simply be `Gyre-Pagella`.


### Key value `math2svg_ex`
This positive integer key value sets the `ex` unit in pixels.
The default value is `6` pixels.


### Key value `math2svg_width`
This positive integer key value sets the container width in `ex` units for line
breaking and tags. The default value is `100` ex.


### Key value `math2svg_extensions`
This string key value allows to load one or more comma separated
[MathJax extensions for TeX and LaTeX][mathjax.tex.ext] present on the system.
These MathJaX extensions reside in a subdirectory of the `mathjax-node-cli`
installation directory.

Take for example, the installation directory of the extensions is
`/usr/local/lib/node_modules/mathjax-node-cli/node_modules/mathjax/unpacked/extensions/`
It contains a subdirectory `TeX` with the extension file `AMSmath.js`.
This MathJaX extension can be loaded by specifying the string `'TeX/AMSmath'`
as the value of the `math2svg_extensions` key.


### Adding `header-includes`
It might turn out useful to systematically include LaTeX macros, for example as
shown below, a series of `\newcommand`.

```latex
---
header-includes: |
    \newcommand{\j}{\text{j}}
    \newcommand{\e}[1]{\,\text{e}^{#1}}
...
```

This may be achieved either by adding a [YAML][yaml] block with the
[`header-includes`][panoc.header-includes] key value at the top of the input
document, or by having a separate YAML document loaded before the input
document. In the latter case, simply evoke `pandoc` as follows:

```bash
pandoc --mathml --filter='math2svg.lua' header-includes.yaml input.md
```


## Privacy

No Internet connection is established when creating MathJax SVG code using
the `tex2svg` command of [`mathjax-node-cli`][mathjax.node.cli].
Nor will any Internet connection be established when viewing an SVG formula.

Hence, formulas in SVG can be created and viewed offline whilst remaining
private.

For code auditing, see also:

- <https://github.com/mathjax/MathJax-node>
- <https://github.com/pkra/mathjax-node-sre>
- <https://github.com/mathjax/mathjax-node-cli>


## License

Copyright (c) 2020 Serge Y. Stroobandt

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## Contact

```bash
$ echo c2VyZ2VAc3Ryb29iYW5kdC5jb20K |base64 -d
```


[latex.math]: https://en.wikibooks.org/wiki/LaTeX/Mathematics

[mathjax]: https://www.mathjax.org/
[mathjax.fonts]: https://docs.mathjax.org/en/latest/output/fonts.html
[mathjax.node.cli]: https://github.com/mathjax/mathjax-node-cli
[mathjax.tex.ext]: https://docs.mathjax.org/en/latest/input/tex/extensions.html
[mathml]: https://en.wikipedia.org/wiki/MathML

[pandoc]: https://pandoc.org/
[pandoc.header-includes]: https://pandoc.org/MANUAL.html#metadata-blocks
[pandoc.lua-filters]: https://pandoc.org/lua-filters.html
[pandoc.metadata]: https://pandoc.org/MANUAL.html#reader-options
[prince]: https://www.princexml.com

[svg]: https://en.wikipedia.org/wiki/Scalable_Vector_Graphics

[w3c]: https://www.w3.org/TR/css-page-3/

[yaml]: https://en.wikipedia.org/wiki/YAML
