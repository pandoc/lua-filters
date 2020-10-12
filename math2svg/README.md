# math2svg


## Description

This [Lua filter](https://pandoc.org/lua-filters.html)
for [Pandoc](https://pandoc.org/)
converts [LaTeX math](https://en.wikibooks.org/wiki/LaTeX/Mathematics)
to [MathJax](https://www.mathjax.org/) generated
[scalable vector graphics (SVG)](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics)
in any of the [available MathJax fonts](https://docs.mathjax.org/en/latest/output/fonts.html).

This is useful when a CSS paged media engine cannot process complex JavaScript
as required by MathJax.
See: <https://www.print-css.rocks> for information about CSS paged media,
a [W3C standard](https://www.w3.org/TR/css-page-3/).

No Internet connection is required for SVG conversions, resulting in absolute privacy.


## Requirements

First, use the package manager of your operating system to install
`pandoc`, `nodejs` and `npm`. `brew` and `choco` are recommended package mangers for
respectively macOS and Windows. See: <https://pandoc.org/installing.html>

```bash
$ sudo apt install pandoc nodejs npm
$ sudo dnf install pandoc nodejs npm
$ sudo yum install pandoc nodejs npm
$ brew install pandoc nodejs npm
> choco install pandoc nodejs npm
```

Then, install `mathjax-node-cli` using `npm`.
Leave out the `sudo` on Windows.

```bash
$ sudo npm install --global mathjax-node-cli
> npm install --global mathjax-node-cli
```


## Usage

To be used as a [Pandoc Lua filter](https://pandoc.org/lua-filters.html).
[MathML](https://en.wikipedia.org/wiki/MathML) should be set as a fallback.

```bash
pandoc --mathml --filter='math2svg.lua'
```


## Privacy

No Internet connection is established when creating MathJax SVG code using
the `tex2svg` command of [`mathjax-node-cli`](https://github.com/mathjax/mathjax-node-cli).
Hence, formulas in SVG can be created offline and will remain private.
For code auditing, see also:

- <https://github.com/mathjax/MathJax-node>
- <https://github.com/pkra/mathjax-node-sre>


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
