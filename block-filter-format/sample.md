---
author: me
title: Thesis
---

# Exluded always

```{exclude-if-format=native;json}
echo "hello" || exit 1 // excluded code block
```

# Test A

Should all be exluded in `json`:

```{include-if-format=native exclude-if-format=json}
ls -al || exit 1 // included excluded code block
```

## Header {include-if-format=native exclude-if-format=json}

:::{include-if-format=native exclude-if-format=json}
A included/excluded div
:::

![Included excluded image](image.svg){include-if-format=native exclude-if-format=json}

`included/excluded code`{include-if-format=native exclude-if-format=json}

# Test B

Should all be exluded in `native`:

```{include-if-format=json exclude-if-format=native}
ls -al || exit 1 // included excluded code block
```

## Header {include-if-format=json exclude-if-format=native}

:::{include-if-format=json exclude-if-format=native}
A included/excluded div
:::

![Included excluded image](image.svg){include-if-format=json exclude-if-format=native}

`included/excluded code`{include-if-format=json exclude-if-format=native}
