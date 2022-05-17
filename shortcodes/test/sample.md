---
title: "Sample"
author: "Norah Jones"
date: "May 22, 2022"
var1: foo
var2: "{{< meta var1 >}}"
shortcodes:
  - test/toupper.lua
  - test/date.lua
---

## Block 

{{< meta title >}}

{{< pagebreak >}}


## Inline

This article was written by {{< meta author >}}.

This reads the `FOO` environment var: {{< env FOO >}}.

## YAML

{{< meta var2 >}}

## Code

`{{< meta title >}}`

```
{{< meta date >}}
```

## Raw

`<a href="#">{{< meta title >}}</a>`{=html}


```{=html}
<strong>{{< meta author >}}</strong>
```

## Escape

{{{< meta title >}}}

```
{{{< meta author >}}
```

## Disable

```{shortcodes="false"}
{{< meta author >}}
```

## Custom 

{{< toupper _make this uppercase_ >}}

The current date is {{< current-date >}}.

The current year is {{< current-date %Y >}}.

