---
title : Test

---

# column-div test
content...

::: {#thisdivdoesnothing}
content...
:::

## Three columns
::: {.anotherclassname .multicols column-count="3"}
content...

content...

content...
:::

## Two uneven columns
:::::: {.columns}
::: {.column width="30%" valign="b"}
contents...
:::
::: {.column width="70%" valign="b"}
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


## Columns and Colors

:::::: {.columns}
::: {.column width="40%" color="blue"}
blue content...
:::
::: {.column width="60%" background-color="red"}
content on red background...
:::
::::::

:::::: {.columns}
::: {.column width="60%" color="blue" background-color="red"}
blue content  on red background...
:::
::: {.column width="40%" }
contents...
:::
::::::