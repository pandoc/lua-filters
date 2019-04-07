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

Example usage:

```{.plantuml caption="This is an image, created by **PlantUML**."}
@startuml
Alice -> Bob: Authentication Request Bob --> Alice: Authentication Response
Alice -> Bob: Another authentication Request Alice <-- Bob: another authentication Response
@enduml
```

### Graphviz
To use Graphviz you only need to install Graphviz, as you can read
on its [website](http://www.graphviz.org/). There are no other
dependencies.

This filter assumes that the `dot` command is located in the path
and therefore can be used from any location. Alternatively, you can
set the environment variable `DOT` or use the pandoc's meta variable
`dot_path`.

Example usage from [the Graphviz gallery](https://graphviz.gitlab.io/_pages/Gallery/directed/fsm.html):

```{.graphviz caption="This is an image, created by **Graphviz**'s dot."}
digraph finite_state_machine {
	rankdir=LR;
	size="8,5"
	node [shape = doublecircle]; LR_0 LR_3 LR_4 LR_8;
	node [shape = circle];
	LR_0 -> LR_2 [ label = "SS(B)" ];
	LR_0 -> LR_1 [ label = "SS(S)" ];
	LR_1 -> LR_3 [ label = "S($end)" ];
	LR_2 -> LR_6 [ label = "SS(b)" ];
	LR_2 -> LR_5 [ label = "SS(a)" ];
	LR_2 -> LR_4 [ label = "S(A)" ];
	LR_5 -> LR_7 [ label = "S(b)" ];
	LR_5 -> LR_5 [ label = "S(a)" ];
	LR_6 -> LR_6 [ label = "S(b)" ];
	LR_6 -> LR_5 [ label = "S(a)" ];
	LR_7 -> LR_8 [ label = "S(b)" ];
	LR_7 -> LR_5 [ label = "S(a)" ];
	LR_8 -> LR_6 [ label = "S(b)" ];
	LR_8 -> LR_5 [ label = "S(a)" ];
}
```

### Tikz
Tikz (cf. [Wikipedia](https://en.wikipedia.org/wiki/PGF/TikZ)) is a
description language for graphics of any kind that can be used within
LaTeX (cf. [Wikipedia](https://en.wikipedia.org/wiki/LaTeX)).

Therefore a LaTeX system must be installed on the system. The Tikz code is
embedded into a dynamic LaTeX document. This temporary document gets
translated into a PDF document using LaTeX (`pdflatex`). Finally,
Inkscape is used to convert the PDF file to the desired format.

Due to this more complicated process, the use of Tikz is also more
complicated overall. The process is error-prone: An insufficiently
configured LaTeX installation or an insufficiently configured
Inkscape installation can lead to errors. Overall, this results in the following dependencies:

- Any LaTeX installation. This should be configured so that
missing packages are installed automatically. This filter uses the
`pdflatex` command which is available by the system's path. Alternatively,
you can set the `PDFLATEX` environment variable. In case you have to use
a specific LaTeX version on a pandoc document basis, you might set the
`pdflatex_path` meta variable.

- An installation of [Inkscape](https://inkscape.org/).
It is assumed that the `inkscape` command is in the path and can be
executed from any location. Alternatively, the environment
variable `INKSCAPE` can be set with a path. If a specific
version per pandoc document is to be used, the `inkscape_path`
meta-variable can be set.

Example usage from [TikZ examples](http://www.texample.net/tikz/examples/parallelepiped/):

```{.tikz caption="This is an image, created by **Tikz i.e. LaTeX**."}
\begin{tikzpicture}[font=\LARGE] 

% Figure parameters (tta and k needs to have the same sign)
% They can be modified at will
\def \tta{ -10.00000000000000 } % Defines the first angle of perspective
\def \k{    -3.00000000000000 } % Factor for second angle of perspective
\def \l{     6.00000000000000 } % Defines the width  of the parallelepiped
\def \d{     5.00000000000000 } % Defines the depth  of the parallelepiped
\def \h{     7.00000000000000 } % Defines the heigth of the parallelepiped

% The vertices A,B,C,D define the reference plan (vertical)
\coordinate (A) at (0,0); 
\coordinate (B) at ({-\h*sin(\tta)},{\h*cos(\tta)}); 
\coordinate (C) at ({-\h*sin(\tta)-\d*sin(\k*\tta)},
                    {\h*cos(\tta)+\d*cos(\k*\tta)}); 
\coordinate (D) at ({-\d*sin(\k*\tta)},{\d*cos(\k*\tta)}); 

% The vertices Ap,Bp,Cp,Dp define a plane translated from the 
% reference plane by the width of the parallelepiped
\coordinate (Ap) at (\l,0); 
\coordinate (Bp) at ({\l-\h*sin(\tta)},{\h*cos(\tta)}); 
\coordinate (Cp) at ({\l-\h*sin(\tta)-\d*sin(\k*\tta)},
                     {\h*cos(\tta)+\d*cos(\k*\tta)}); 
\coordinate (Dp) at ({\l-\d*sin(\k*\tta)},{\d*cos(\k*\tta)}); 

% Marking the vertices of the tetrahedron (red)
% and of the parallelepiped (black)
\fill[black]  (A) circle [radius=2pt]; 
\fill[red]    (B) circle [radius=2pt]; 
\fill[black]  (C) circle [radius=2pt]; 
\fill[red]    (D) circle [radius=2pt]; 
\fill[red]   (Ap) circle [radius=2pt]; 
\fill[black] (Bp) circle [radius=2pt]; 
\fill[red]   (Cp) circle [radius=2pt]; 
\fill[black] (Dp) circle [radius=2pt]; 

% painting first the three visible faces of the tetrahedron
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (Cp) -- (D);
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (D)  -- (Ap);
\filldraw[draw=red,bottom color=red!50!black, top color=cyan!50]
  (B) -- (Cp) -- (Ap);

% Draw the edges of the tetrahedron
\draw[red,-,very thick] (Ap) --  (D)
                        (Ap) --  (B)
                        (Ap) -- (Cp)
                        (B)  --  (D)
                        (Cp) --  (D)
                        (B)  -- (Cp);

% Draw the visible edges of the parallelepiped
\draw [-,thin] (B)  --  (A)
               (Ap) -- (Bp)
               (B)  --  (C)
               (D)  --  (C)
               (A)  --  (D)
               (Ap) --  (A)
               (Cp) --  (C)
               (Bp) --  (B)
               (Bp) -- (Cp);

% Draw the hidden edges of the parallelepiped
\draw [gray,-,thin] (Dp) -- (Cp);
                    (Dp) --  (D);
                    (Ap) -- (Dp);

% Name the vertices (the names are not consistent
%  with the node name, but it makes the programming easier)
\draw (Ap) node [right]           {$A$}
      (Bp) node [right, gray]     {$F$}
      (Cp) node [right]           {$D$}
      (C)  node [left,gray]       {$E$}
      (D)  node [left]            {$B$}
      (A)  node [left,gray]       {$G$}
      (B)  node [above left=+5pt] {$C$}
      (Dp) node [right,gray]      {$H$};

% Drawing again vertex $C$, node (B) because it disappeared behind the edges.
% Drawing again vertex $H$, node (Dp) because it disappeared behind the edges.
\fill[red]   (B) circle [radius=2pt]; 
\fill[gray] (Dp) circle [radius=2pt]; 

% From the reference and this example one can easily draw 
% the twin tetrahedron jointly to this one.
% Drawing the edges of the twin tetrahedron
% switching the p_s: A <-> Ap, etc...
\draw[red,-,dashed, thin] (A)  -- (Dp)
                          (A)  -- (Bp)
                          (A)  --  (C)
                          (Bp) -- (Dp)
                          (C)  -- (Dp)
                          (Bp) --  (C);
\end{tikzpicture}
```

### Python
In order to use Python to generate an diagram, your Python code must store the final image data in a temporary file with the correct format. In case you use matplotlib for a diagram, add the following line to do so:

```python
plt.savefig("$DESTINATION$", dpi=300, fomat="$FORMAT$")
```

The placeholder `$FORMAT$` gets replace by the necessary format. Most of the time, this will be `png` or `svg`. The second placeholder, `$DESTINATION$` gets replaced by the path and file name of the destination. Both placeholders can be used as many times as you want. Example usage from the (Matplotlib examples)[https://matplotlib.org/gallery/lines_bars_and_markers/cohere.html#sphx-glr-gallery-lines-bars-and-markers-cohere-py]:

```{.py2image caption="This is an image, created by **Python**."}
import sys
import numpy as np
import matplotlib.pyplot as plt

# Fixing random state for reproducibility
np.random.seed(19680801)

dt = 0.01
t = np.arange(0, 30, dt)
nse1 = np.random.randn(len(t))                 # white noise 1
nse2 = np.random.randn(len(t))                 # white noise 2

# Two signals with a coherent part at 10Hz and a random part
s1 = np.sin(2 * np.pi * 10 * t) + nse1
s2 = np.sin(2 * np.pi * 10 * t) + nse2

fig, axs = plt.subplots(2, 1)
axs[0].plot(t, s1, t, s2)
axs[0].set_xlim(0, 2)
axs[0].set_xlabel('time')
axs[0].set_ylabel('s1 and s2')
axs[0].grid(True)

cxy, f = axs[1].cohere(s1, s2, 256, 1. / dt)
axs[1].set_ylabel('coherence')

fig.tight_layout()
plt.savefig("$DESTINATION$", dpi=300, fomat="$FORMAT$")
```

Precondition to use Python is a Python environment which contains all necessary libraries you want to use. To use, for example, the standard [Anaconda Python](https://www.anaconda.com/distribution/) environment on a Microsoft Windows system ...

- set the environment variable `PYTHON` or the meta key `python_path` to `c:\ProgramData\Anaconda3\python.exe`

- set the environment variable `PYTHON_ACTIVATE` or the meta key `activate_python_path` to `c:\ProgramData\Anaconda3\Scripts\activate.bat`.

Pandoc will activate this Python environment and starts Python with your code.

## How to run pandoc
This section will show, how to call Pandoc in order to use this filter with meta keys. The following command assume, that the filters are stored in the subdirectory `filters`. Further, this is a example for a Microsoft Windows system.

Command to use PlantUML:

```
pandoc.exe README.md -f markdown -t docx --self-contained --standalone --lua-filter=filters\diagram_generator.lua --metadata=plantuml_path:"c:\ProgramData\chocolatey\lib\plantuml\tools\plantuml.jar" --metadata=java_path:"c:\Program Files\Java\jre1.8.0_201\bin\java.exe" -o README.docx
```

All available environment variables:

- `PLANTUML` e.g. `c:\ProgramData\chocolatey\lib\plantuml\tools\plantuml.jar`; Default: `plantuml.jar`
- `INKSCAPE` e.g. `c:\Program Files\Inkscape\inkscape.exe`; Default: `inkscape`
- `PYTHON` e.g. `c:\ProgramData\Anaconda3\python.exe`; Default: n/a
- `PYTHON_ACTIVATE` e.g. `c:\ProgramData\Anaconda3\Scripts\activate.bat`; Default: n/a
- `JAVA_HOME` e.g. `c:\Program Files\Java\jre1.8.0_201`; Default: n/a
- `DOT` e.g. `c:\ProgramData\chocolatey\bin\dot.exe`; Default: `dot`
- `PDFLATEX` e.g. `c:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe`; Default: `pdflatex`

All available meta keys:

- `plantuml_path`
- `inkscape_path`
- `python_path`
- `activate_python_path`
- `java_path`
- `dot_path`
- `pdflatex_path`