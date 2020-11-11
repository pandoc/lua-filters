# lilypond
This filter renders [LilyPond](http://lilypond.org) inline code and
code blocks into embedded images of musical notation. It's designed with
(pandoc-flavored) Markdown input in mind.

See the accompanying test files for some examples of how the filter works.

## Rationale
LilyPond is the tool of choice for generating musical notation from
text input.  Integrating it with pandoc lets us write documents that include the
code for musical examples alongside their main content and compile them with a
single command. Because filters operate directly on pandoc's AST, support for
any sufficiently rich output format is free.

The LilyPond distribution includes a program called
[`lilypond-book`](http://lilypond.org/doc/v2.19/Documentation/usage/lilypond_002dbook.en.html)
that's intended to serve a similar purpose. Unfortunately, it has some
significant limitations: only HTML and Texinfo are supported for input,
compilation is messy, and the [source
code](https://git.savannah.gnu.org/cgit/lilypond.git/tree/scripts/lilypond-book.py)
is complex, running to over 700 lines of Python 2. This filter aims to be a
superior alternative.

## Usage
The filter operates on inline code (type `Code`) and code block (type
`CodeBlock`) elements that are marked with the `lilypond` class. Each such
element is replaced by an image element, with the underlying PNG image generated
by feeding the contents of the original element to LilyPond. (Eventually the
filter will support SVG output as well.)

You can configure the filter's behavior in two ways: by adding classes and
attributes to individual code elements, and by adding metadata to the input
document. Classes and attributes naturally only affect the element they're
attached to, while metadata options affect all code elements in the document.

The available classes are:

* `ly-fragment`: the code in this element will be wrapped in some additional
  boilerplate before compilation, meaning you can start writing notes
  immediately without a bunch of setup. Inline code elements are always treated
  as fragments.
* `ly-norender`: this element will be ignored by the filter.

The available (key-value) attributes are:

* `ly-caption`: caption for the image generated from this element.  Default:
  `"Musical notation"`.
* `ly-name`: base filename (without path) for the image generated from this
  element; an file extension will be appended. Default: the SHA1 digest of the
  element's contents.
* `ly-resolution`: resolution (in DPI) for the image generated from this
  element. Default: set by LilyPond.
* `ly-title`: title for the image generated from this element. Default: the
  element's contents.

The available metadata options are:

* `lilypond.image_directory` (string): media sub-directory where
  generated images should be stored. Default: `"."`.

The classes and attributes listed above will *not* be copied to the generated
image, but all other classes and attributes will be, and so will the identifier
if one is present. The `lilypond` block (if present) will be stripped from the
document metadata. Images generated from inline code will be tagged with the
`lilypond-image-inline` class, and those generated from code blocks with the
`lilypond-image-standalone` class.

## Requirements
The `lilypond` executable must be installed to a location on
your `PATH`. You can obtain it [here](http://lilypond.org/download.html) or
through your package manager.

Finally, because `lilypond.lua` uses functions from the `pandoc.system`
submodule, it requires pandoc version 2.7.3 or later.
