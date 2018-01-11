# tikz

This filter converts raw LaTeX tikz environments into images. It
works with both PDF and HTML output. The tikz code is compiled
to an image using `pdflatex`, and the image is converted (if
necessary) from pdf to png format using ImageMagick's `convert`,
so both of these must be in the system path. Converted images
are cached in the working directory and given filenames based on
a hash of the source, so that they need not be regenerated each
time the document is built. (A more sophisticated version of
this might put these in a special cache directory.)

To run it, `pandoc --lua-filter tikz.lua myfile.md -s -o myfile.html`.
