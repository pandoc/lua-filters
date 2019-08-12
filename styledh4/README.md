# styledh4

This filter lets you style a fourth level heading in LaTeX, i.e. `\subsubsubsection`.
Read about the problem in the [Tex FAQ](https://texfaq.org/FAQ-subsubsub), [Dickimaw Books article](https://www.dickimaw-books.com/latex/novices/html/sectionunits.html), or the following [Stack Overflow post](https://stackoverflow.com/questions/21198025/pandoc-generation-of-pdf-from-markdown-not-respecting-headers-formatting).

You can customize the raw LaTeX in `styledh4.lua`.
Run the filter by passing it to pandoc with the `--lua-filter` flag:
```
$ pandoc --lua-filter styledh4.lua myfile.md -o myfile.latex
```
