# math-katex


## Description

This [Lua filter][pandoc.lua-filters] for [Pandoc][pandoc] converts
[LaTeX math][latex.math] to [Katex][katex] generated html doc for insertion into
the output document in a standalone manner.


This is useful if you prefer to render your maths at build time.

No Internet connection is required when generating or viewing formulas,
resulting in both absolute privacy and offline, standalone robustness.


## Version history

- 2022-01-04: Initial release


## Requirements

First, use the package manager of your operating system to install `pandoc`,
`nodejs` and `npm`. `brew` and `choco` are recommended package managers for
respectively macOS and Windows. See: <https://pandoc.org/installing.html>

```bash
$ sudo apt install pandoc nodejs npm
$ sudo dnf install pandoc nodejs npm
$ sudo yum install pandoc nodejs npm
$ brew install pandoc nodejs npm
> choco install pandoc nodejs npm
```

Then, by means of node's package manager `npm`, install the `katex` package.
This package comes with the `katex` executable. Leave out the `sudo` on Windows.

```bash
$ sudo npm install --global katex
> npm install --global katex
```


## Usage

To be used as a [Pandoc Lua filter][pandoc.lua-filters].

```bash
pandoc --filter='math-katex.lua'
```

The math-katex filter is entirely configurable over
[`--metadata` key value pairs](pandoc.metadata).
Ten configuration keys are available with sensible default values.
Hence, depending on your system and intentions, not all keys are necessarily
required.

|              key               |   default value   |
| :----------------------------- | :---------------: |
| `math_katex_bin`               |     `'katex'`     |
| `math_katex_no_throw_on_error` |      `false`      |
| `math_katex_format`            | `'htmlAndMathml'` |


### Key value `math_katex_bin`

This string key value is only required when, on your system, the path to the
`katex` executable of the `katex` package is not present in the `$PATH`
environment variable.

The full path to `katex` can be found with the following command on \*nix,
respectively Windows:

```bash
$ which -a katex
> where katex
```

### Key value `math_katex_no_throw_on_error`

This boolean key value specify whether katex render errors instead of throwing a
ParseError exception when encountering an error. The default is `false`.


### Key value `math_katex_format`

This string key value determines the markup language of the output. The default
is `false`.

## Adding katex css

For rendering katex maths you must include the `katex.css` file included in the
katex package or available via cdn:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.15.1/dist/katex.min.css" integrity="sha384-R4558gYOUz8mP9YWpZJjofhk+zx0AS11p36HnD2ZKj/6JR5z27gSSULCNHIRReVs" crossorigin="anonymous">
```

## Privacy

No Internet connection is established when creating html code using
the `katex` command.
Nor will any Internet connection be established when viewing the html page.

Hence, formulas rendered with [katex] can be created and viewed offline whilst
remaining private.

For code auditing, see also:

- <https://github.com/mathjax/MathJax-node>
- <https://github.com/pkra/mathjax-node-sre>
- <https://github.com/mathjax/mathjax-node-cli>


## License

Copyright © 2022 Benjamin Abel <dev.abel@free.fr>

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


[latex.math]: https://en.wikibooks.org/wiki/LaTeX/Mathematics

[katex]: https://katex.org
[pandoc]: https://pandoc.org/
[pandoc.lua-filters]: https://pandoc.org/lua-filters.html
[pandoc.metadata]: https://pandoc.org/MANUAL.html#reader-options
