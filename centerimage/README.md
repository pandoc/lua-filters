# centerimage

This filter centers images when converting markdown to LaTeX.
It is based on the TeX answer [here.](https://tex.stackexchange.com/questions/46903/centering-with-includegraphics-not-with-beginfigure)

Run the filter by passing it to pandoc with the `--lua-filter` flag:
```
$ pandoc --lua-filter centerimage.lua myfile.md -o myfile.latex
```
