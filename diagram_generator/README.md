# Diagram Generator Lua Filter

## Introduction
This Lua filter is used to create images with or without captions from code
blocks. Currently PlantUML, Graphviz, Tikz and Python can be processed.
This document also serves as a test document, which is why the subsequent
test diagrams are integrated in every supported language.

## Prerequisites
To be able to use this Lua filter, the respective external tools must be
installed. However, it is sufficient if the tools to be used are installed.
If you only want to use PlantUML, you don't need LaTeX or Python, etc.

### PlantUML
To use PlantUML, you must install PlantUML itself. See the
[PlantUML website](http://plantuml.com/) for more details. It should be
noted that PlantUML is a Java program and therefore Java must also
be installed.

By default, this filter expects the plantuml.jar file to be in the
working directory. Alternatively, the environment variable
`PLANTUML` can be set with a path. If, for example, a specific
PlantUML version is to be used per pandoc document, the
`plantuml_path` meta variable can be set.

Furthermore, this filter assumes that Java is located in the
system or user path. This means that from any place of the system
the `java` command is understood. Alternatively, the `JAVA_HOME`
environment variable gets used. To use a specific Java version per
pandoc document, use the `java_path` meta variable.

### GraphViz
To use GraphViz you only need to install Graphviz, as you can read
on its [website](http://www.graphviz.org/). There are no other
dependencies.

This filter assumes that the `dot` command is located in the path
and therefore can be used from any location. Alternatively, you can
set the environment variable `DOT` or use the pandoc's meta variable
`dot_path`.

### Tikz
Tikz (cf. [Wikipedia](https://en.wikipedia.org/wiki/PGF/TikZ)) is a
description language for graphics of any kind that can be used within
LaTeX (cf. [Wikipedia](https://en.wikipedia.org/wiki/LaTeX)).

Therefore a LaTeX system must be installed on the system. The Tikz code is
embedded into a dynamic LaTeX document. This temporary document gets
translated into a PDF document using LaTeX (`pdflatex`). Finally,
ImageMagick is used to convert the PDF file to the desired format.

Due to this more complicated process, the use of Tikz is also more
complicated overall. The process is error-prone: An insufficiently
configured LaTeX installation or an insufficiently configured
ImageMagick installation can lead to errors.

ImageMagick also requires a Ghostscript installation to convert
PDF files. Overall, this results in the following dependencies:

- Any LaTeX installation. This should be configured so that
missing packages are installed automatically. This filter uses the
`pdflatex` command which is available by the system's path. Alternatively,
you can set the `PDFLATEX` environment variable. In case you have to use
a specific LaTeX version on a pandoc document basis, you might set the
`pdflatex_path` meta variable.

- An installation of [ImageMagick](http://www.imagemagick.org/).
It is assumed that the convert command is in the path and can be
executed from any location. Alternatively, the environment
variable `CONVERT` can be set with a path. If a specific
version per pandoc document is to be used, the `convert_path`
meta-variable can be set.

- Finally, an installation of
[Ghostscript](https://www.ghostscript.com/) is required.

### Python

### Using Package Managers

## Example in markdown-file
```{.plantuml caption="This is my caption."}
@startuml
Alice -> Bob: Authentication Request Bob --> Alice: Authentication Response
Alice -> Bob: Another authentication Request Alice <-- Bob: another authentication Response
@enduml
```
## Run pandoc
```
pandoc --self-contained --lua-filter=plantuml.lua readme.md -o output.htm
```

