The table below exists in two versions. The LaTeX version will be used in `latex` and `beamer` and the markdown version in all other output formats.

::: {.not-in-format .latex .beamer}

---------------------------
This table   is not kept
----------- ----------------
in formats    latex, beamer
----------------------------

:::

~~~{=latex}

begin{tabular}{|c|c|}
\toprule
This table & is used \\ \addlinespace
\midrule
\endhead
in formats & latex, beamer \\ \addlinespace
\bottomrule
\end{tabluar}

~~~
