# commonmark-code-blocks 

This filter produces code blocks with language CSS class format
suggested by the CommonMark specification ("language-$lang").

The CommonMark spec suggests that converting ````somelang` to HTML
should produce `<code class="language-somelang">`,
as described in [example 141](https://spec.commonmark.org/0.30/#example-141).

That's what most CommonMark implementations do.
Pandoc, however, outputs `<code class="somelang">` instead.

That can be a problem for syntax highlighters that expect
`language-*` classes and use them to determine the language.
 
This filter takes over the code block rendering process
to produce CommonMark-style output.

## Usage

This filter does not require any setup or external tools.
Just run pandoc with `--lua-filter=commonmark-code-blocks.lua`.

