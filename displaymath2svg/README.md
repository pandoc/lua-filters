# Description

This [Lua filter](https://pandoc.org/lua-filters.html)
for [Pandoc](https://pandoc.org/)
converts [LaTeX DisplayMath](https://en.wikibooks.org/wiki/LaTeX/Mathematics)
to [MathJax](https://www.mathjax.org/) generated
[scalable vector graphics (SVG)](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics)
in any of the available [MathJax fonts](https://docs.mathjax.org/en/latest/output/fonts.html).

This is useful when a CSS paged media engine cannot process complex JavaScript
as required by MathJax.
See: <https://www.print-css.rocks> for information about CSS paged media,
a [W3C standard](https://www.w3.org/TR/css-page-3/).

This filter also defines the missing LaTeX commands `\j` and `\e{}` for displaying
the imaginary unit j and the exponential function with Euler constant e.


# Requires

```bash
$ sudo apt install pandoc pandoc-citeproc libghc-pandoc-prof nodejs npm
$ sudo npm install --global mathjax-node-cli
```


# Usage

To be used as a [Pandoc Lua filter](https://pandoc.org/lua-filters.html).

```bash
pandoc --mathml --filter='displaymath2svg.lua'
```


# Privacy

No Internet connection is established when creating MathJax SVG code using
the `tex2svg` command of [`mathjax-node-cli`](https://github.com/mathjax/mathjax-node-cli).
Hence, formulas in SVG can be created offline and remain private.
For code auditing, see also:

    - <https://github.com/mathjax/MathJax-node>
    - <https://github.com/pkra/mathjax-node-sre>


# Copyright

Copyright 2020 Serge Y. Stroobandt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.


# Contact

```bash
$ echo c2VyZ2VAc3Ryb29iYW5kdC5jb20K |base64 -d
```
