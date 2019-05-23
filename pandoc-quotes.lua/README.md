# pandoc-quotes.lua

`pandoc-quotes.lua` is a filter for [Pandoc](https://www.pandoc.org/) that
replaces non-typographic quotation marks with typographic ones for languages
other than US English.

You can define which typographic quotation marks to replace plain ones with by
setting either a document's `quot-marks`, `quot-lang`, or `lang` metadata
field. Typically, it should 'just work'.

See the [manual page](man/pandoc-quotes.lua.md) for details.


## Installing `pandoc-quotes.lua`

You use `pandoc-quotes.lua` **at your own risk**. You have been warned.

### Requirements

You need [Pandoc](https://www.pandoc.org/) 2.0 or later.


### Installation

1. Download the 
   [latest release](https://github.com/odkr/pandoc-quotes.lua/releases/latest).
2. Unpack it.
3. Move `pandoc-quotes.lua` from the repository directory to the
   `filters` sub-directory of your Pandoc data directory
   (`pandoc --version` will tell you where that is).

### POSIX-compliant systems

If you have [curl](https://curl.haxx.se/) or 
[wget](https://www.gnu.org/software/wget/), you can (probably)
install `pandoc-quotes.lua` by copy-pasting the
following commands into a bourne shell:

```sh
(
    set -Cefu
    NAME=pandoc-quotes.lua VERS=0.1.8
    URL="https://github.com/odkr/${NAME:?}/archive/v${VERS:?}.tar.gz"
    FILTERS="${HOME:?}/.pandoc/filters"
    mkdir -p "${FILTERS:?}"
    {
        curl -L "$URL" || ERR=$?
        [ "${ERR-0}" -eq 127 ] && wget -q -O - "$URL"
    } | tar xz
    mv "$NAME-$VERS/pandoc-quotes.lua" "$FILTERS"
)
```

You may also want to copy the manual page from the `man` directory in the
repository to wherever your operating system searches for manual pages.


## Test suite

For the test suite to work, you need a POSIX-compliant operating system,
[make](https://en.wikipedia.org/wiki/Make_(software)), and
[Pandoc](https://www.pandoc.org/) 2.7.2. The test suite may or may not
work with other versions of Pandoc.

To run the test suite, just say:

```sh
    make test
```

## Documentation

See the [manual page](man/pandoc-quotes.lua.md)
and the source for details.


## Contact

If there's something wrong with `pandoc-quotes.lua`, 
[open an issue](https://github.com/odkr/pandoc-quotes.lua/issues).


## License

Copyright 2018, 2019 Odin Kroeger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


## Further Information


GitHub:
    <https://github.com/odkr/pandoc-quotes.lua>
