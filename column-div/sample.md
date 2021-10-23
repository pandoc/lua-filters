---
title : Test
header-includes:
    - |
      ```{=latex}
      \usepackage{multicol}

      ```
---

# column-div test
content...

## Three columns
::: {.multicols column-count="3"}
content...

content...

content...
:::

## Two unbalanced columns
:::::: {.columns}
::: {.column width="40%" valign="b"}
contents...
:::
::: {.column width="60%" valign="b"}
contents...
:::
::::::

## Columns in columns

::::::::: {.multicols column-count="3"}
:::::: {.columns}
::: {.column width="20%" valign="b"}
contents...
:::
::: {.column width="80%" valign="b"}
contents...
:::
::::::
:::::: {.columns}
::: {.column width="20%" valign="b"}
contents...
:::
::: {.column width="80%" valign="b"}
contents...
:::
::::::
:::::: {.columns}
::: {.column width="20%" valign="b"}
contents...
:::
::: {.column width="80%" valign="b"}
contents...
:::
::::::
:::::::::