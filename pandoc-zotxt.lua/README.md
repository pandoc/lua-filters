# pandoc-zotxt.lua

`pandoc-zotxt.lua` looks up sources of citations in 
[Zotero](https://www.zotero.org/) and adds them either to a
document's `references` metadata field or to a bibliography
file , where `pandoc-citeproc` can pick them up.

`pandoc-zotxt.lua` requires [zotxt](https://github.com/egh/zotxt/). It
supports [Better BibTeX for Zotero](https://retorque.re/zotero-better-bibtex/),
hereafter "Better BibTeX" for short.

See the [manual page](man/pandoc-zotxt.lua.md) for more details.


## Installing `pandoc-zotxt.lua`

You use `pandoc-zotxt.lua` **at your own risk**. You have been warned.

### Requirements

`pandoc-zotxt.lua` should run under any POSIX-compliant operating system 
(e.g., macOS, FreeBSD, OpenBSD, NetBSD, Linux) and under Windows. It has
*not* been tested under Windows, however.

You need [Pandoc](https://www.pandoc.org/) 2.0 or later. If you are using
an older version of Pandoc, try [pandoc-zotxt](https://github.com/egh/zotxt),
which works with Pandoc 1.12 or later (but also requires 
[Python](https://www.python.org/) 2.7).

### Installation

1. Download the 
   [latest release](https://github.com/odkr/pandoc-zotxt.lua/releases/latest).
2. Unpack it.
3. Move the repository directory to the `filters` sub-directory of your
   Pandoc data directory (`pandoc --version` will tell you where that is).
4. Move the file `pandoc-zotxt.lua` from the repository directory
   up into the `filters` directory.

### POSIX-compliant systems

If you have [curl](https://curl.haxx.se/) or 
[wget](https://www.gnu.org/software/wget/), you can
install `pandoc-zotxt.lua` by copy-pasting the
following commands into a bourne shell:

```sh
(
    set -Cefu
    NAME=pandoc-zotxt.lua VERS=0.3.17
    URL="https://github.com/odkr/${NAME:?}/archive/v${VERS:?}.tar.gz"
    FILTERS="${HOME:?}/.pandoc/filters"
    mkdir -p "${FILTERS:?}"
    cd -P "$FILTERS" || exit
    {
        curl -L "$URL" || ERR=$?
        [ "${ERR-0}" -eq 127 ] && wget -O - "$URL"
    } | tar xz
    mv "$NAME-$VERS/pandoc-zotxt.lua" .
)
```

You may also want to copy the manual page from the `man` directory in the
repository to wherever your operating system searches for manual pages.


## `pandoc-zotxt.lua` vs `pandoc-zotxt`

| `pandoc-zotxt.lua`            | `pandoc-zotxt`                       |
| ----------------------------- | ------------------------------------ |
| Requires Pandoc 2.0.          | Requires Pandoc 1.12 and Python 2.7. |
| Faster for Better BibTeX.     | Slower for Better BibTeX.            |
| Doesn't use temporary files.  | Uses a temporary file.               |


Morever, `pandoc-zotxt.lua` supports:

* Updating a JSON bibliography.
* Using Zotero item ID as citation keys.


## Testing

### The default test suite

#### Requirements

1. A POSIX-compliant operating system
2. [Python](https://www.python.org/) 2.7, 3.5, or later.
3. [Pandoc](https://www.pandoc.org/) 2.7.2
4. [pandoc-citeproc](https://github.com/jgm/pandoc-citeproc) 0.16.1.3

#### Assumptions

The default test suit only assumes that you are using the Citation Style
Language stylesheet that ships with `pandoc-citeproc`, namely, 
`chicago-author-date.csl`.

#### Execution

Simply say:

```
    make test
```

### The real-world test suite

The default test suite spins up a simple HTTP server pretending to be Zotero.
(This is what it needs Python for.) Alternatively, you can run the tests
using the real Zotero, with *zotxt* and Better BibTeX installed. (But you
really don't want to do this.)

#### Requirements

1. A POSIX-compliant operating system
2. Zotero
3. *zotxt*
4. Better BibTeX
5. [Pandoc](https://www.pandoc.org/) 2.7.2
6. [pandoc-citeproc](https://github.com/jgm/pandoc-citeproc) 0.16.1.3

#### Assumptions

The real-world test suite makes the same assumptions as the default one, plus:

1. You have imported the sources cited in the test documents.
   You can import those into Zotero from `test/items.rdf`.

2. You don't have any sources in your Zotero database that
   match the same easy citekeys as those in `test/items.rdf`.
   (If you do, you'll need to adapt them.)
 
3. You hat set your Better BibTex citation key format to:
  "[auth:lower][year][shorttitle3_3]". 

4. You have modified the both test suites, the default and the real world one,
   to refer to the Zotero item IDs of your Zotero database.

#### Adapting Zotero item IDs

Two sources are looked up by their Zotero item ID:

1. Sally Haslanger's *Resisting Reality*
2. Kristie Dotson's "A Cautionary Tale: On Limiting Epistemic Oppression"

You must adapt the tests for these lookups, so that they use the
IDs that these sources have in *your* Zotero database. 

You can look up those IDs by searching for those sources in your [Zotero
online library](https://zotero.org/). Their URLs should end in:
"/*yourUsername*/items/itemKey/**ABCD1234**". That last part is the item ID.

You need to make changes to two files:

`test/unit/test.lua`: 
    Change the assignment for `zotero_id.id` in the function 
    `test_retrieval:test_get_source` from `TPN8FXZV` to
    the ID of Haslanger's *Resiting Reality* in your database.

`test/data/test-keytype-zotero-id.md`:
    Change `QN9S6E2T` to the ID of Dotson's "A Cautionary Tale".

You also need to rename `key=TPN8FXZV` and `key=QN9S6E2T` in 
`test/data/http-server` accordingly.

#### Execution

Say:

```
    make test -e NO_HTTP_SERVER=true
```


## Documentation

See the [manual page](man/pandoc-zotxt.lua.md)
and the source for details.


## Contact

If there's something wrong with `pandoc-zotxt.lua`, 
[open an issue](https://github.com/odkr/pandoc-zotxt.lua/issues).


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
    <https://github.com/odkr/pandoc-zotxt.lua>
