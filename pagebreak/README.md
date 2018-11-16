pagebreak
=========

This filter converts paragraps containing only the LaTeX
`\newpage` or `\pagebreak` command into appropriate pagebreak
markup for other formats. The command must be the only contents
of a raw TeX block in order to be recognized. I.e., for Markdown
the following is sufficient:

    Paragraph before page break

    \newpage

    Paragraph after page break


Usage
-----

Fully supported output formats are:

- Docx,
- LaTeX,
- HTML, and
- EPUB.

ODT is supported, but requires additional settings in the
reference document (see below).

In all other formats, the page break is represented using the
form feed character.


### Usage with HTML
If you want to use an HTML class rather than an inline style set
the value of the metadata key `newpage_html_class` or the
environment variable `PANDOC_NEWPAGE_HTML_CLASS` (the metadata
'wins' if both are defined) to the name of the class and use CSS
like this:

    @media all {
        .page-break	{ display: none; }
    }
    @media print {
        .page-break	{ display: block; page-break-after: always; }
    }


### Usage with ODT

To use with ODT you must create a reference ODT with a named
paragraph style called `Pagebreak` (or whatever you set the
metadata field `newpage_odt_style` or the environment variable
`PANDOC_NEWPAGE_ODT_STYLE` to) and define it as having no extra
space before or after but set it to have a pagebreak after it
<https://help.libreoffice.org/Writer/Text_Flow>.

(There will be an empty dummy paragraph, which means some extra
vertical space, and you probably want that space to go at the
bottom of the page before the break rather than at the top of
the page after the break!)


Alternative syntax
------------------

The form feed character as the only element in a paragraph is
supported as an alternative to the LaTeX syntax described above.
