# mhchem

[mhchem] is a widely-used LaTeX package for chemical notation.
It is not understood natively by pandoc's LaTeX reader. This
filter replaces any `\ce{}` commands in RawInline, RawBlock,
and Math elements, with Math elements that can be reliably
converted to other formats by pandoc.

## Usage

To convert a LaTeX document containing mhchem macros
to docx, do

    pandoc -f latex+raw_tex -L mhchem.lua input.tex -o output.docx

The `-f latex+raw_tex` part is essential; it ensures that
bare `\ce{}` commands will be included in the pandoc AST as
raw TeX, so that this filter can see them.

Related work:

- <https://github.com/mhchem/mhchemParser/>

