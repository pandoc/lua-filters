pagebreak
=========

Turn the LaTeX command `\newline` into proper page breaks. The
command must be the only contents of a raw TeX block in order to
be recognized.  I.e., for Markdown the following is sufficient:

    Paragraph before page break

    \newpage

    Paragraph after page break


Supported formats
-----------------

Fully supported output formats are:

- Docx,
- LaTeX,
- HTML, and
- EPUB.

In all other formats, the page break is represented using the
form feed character.


Alternative syntax
------------------

The form feed character as the only element in a paragraph is
supported as an alternative to the LaTeX syntax described above.
