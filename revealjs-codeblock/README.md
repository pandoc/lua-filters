# revealjs-codeblock

This filter overwrites the code block HTML for `revealjs` output to
enable the [code presenting features](https://revealjs.com/code/) of
[reveal.js](https://revealjs.com/). A custom template is required to
include [highlight.js](https://highlightjs.org/) (which [comes with
reveal.js](https://revealjs.com/code/#theming) as a plugin).

## Features

The filter passes the code block attributes to reveal.js. This enables
the following reveal.js features:

- [Line Numbers &
  Highlights](https://revealjs.com/code/#line-numbers-%26-highlights)
  via the `data-line-numbers` attribute. (`.numerLines` and
  `.number-lines` classes are converted for compatibility.)
- [Line Number
  Offset](https://revealjs.com/code/#line-number-offset-4.2.0) (via
  `data-ln-start-from` and `startFrom` attributes)
- [Step-by-step
  Highlights](https://revealjs.com/code/#step-by-step-highlights)
- [Auto-Animation](https://revealjs.com/auto-animate/#example%3A-animating-between-code-blocks)
  of code blocks with line numbers and a `data-id`. (The slide
  headings need the `data-auto-animate` attribute.)

## Usage

You have to [include highlight.js](https://revealjs.com/code/#theming)
in your own custom template or use the provided `template.html`. It has
two additional variables:

- `highlightjs` to opt in highlight.js (default to false)
- `highlightjs-theme` to select a theme. Currently reveal.js
  [comes](https://github.com/hakimel/reveal.js/tree/master/plugin/highlight)
  with `monokai` (default) and `zenburn`.

``` bash
$ pandoc sample.md -o sample.html -t revealjs -L revealjs-codeblock.lua \
  --template template.html -V highlightjs -V highlightjs-theme:zenburn
```

## Example

See `sample.md` for a recreation of the [code presentation
demo](https://revealjs.com/#/4).
