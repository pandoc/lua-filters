---
title: PANDOC-QUOTES.LUA(1)
author: Odin Kroeger
Date: May 9, 2019
---

# NAME

pandoc-quotes.lua - Replaces plain quotation marks with typographic ones


# SYNOPSIS

**pandoc** **--lua-filter** *pandoc-quotes.lua*


# DESCRIPTION

**pandoc-quotes.lua** is a filter for **pandoc** that replaces non-typographic
quotation marks with typographic ones for languages other than US English.

You can define which typographic quotation marks to replace plain ones with
by setting either a document's *quot-marks*, *quot-lang*, or *lang*
metadata field. If none of these is set, **pandoc-quotes.lua** does nothing.

You can add your own mapping of a language to quotation marks or override
the default ones by setting *quot-marks-by-lang*.

## quot-marks

A list of four strings, where the first item lists the primary left quotation
mark, the second the primary right quotation mark, the third the secondary
left quotation mark, and the fourth the secondary right quotation mark.

For example:

```yaml
---
quot-marks:
    - ''
    - ''
    - '
    - '
...
```

You always have to set all four.

If each quotation mark consists of one character only,
you can write the whole list as a simple string.

For example:

```yaml
---
quot-marks: ""''
...
```

If *quot-marks* is set, the other fields are ignored.


# quotation-lang

An RFC 5646-like code for the language the quotation marks of
which shall be used (e.g., "pt-BR", "es").

For example:

```yaml
---
quot-lang: de-AT
...
```

**Note:** Only the language and the country tags of RFC 5646 are supported.
For example, "it-CH" (i.e., Italian as spoken in Switzerland) is fine, 
but "it-756" (also Italian as spoken in Switzerland) will return the quotation
marks for "it" (i.e., Italian as spoken in general).

If *quot-marks* is set, *quot-lang* is ignored.


# lang

The format of *lang* is the same as for *quot-lang*. If *quot-marks*
or *quot-lang* is set, *lang* is ignored. 

For example:

```yaml
---
lang: de-AT
...
```


# ADDING LANGUAGES

You can add quotation marks for unsupported languages, or override the
defaults, by setting the metadata field *quot-marks-by-lang* to a maping
of RFC 5646-like language codes (e.g., "pt-BR", "es") to lists of quotation
marks, which are given in the same format as for the *quot-marks*
metadata field.

For example:

```yaml
---
quot-marks-by-lang:
    abc-XYZ: ""''
lang: abc-XYZ
...
```


# CAVEATS

**pandoc** represents documents as abstract syntax trees internally, and
quotations are nodes in that tree. However, **pandoc-quotes.lua** replaces
those nodes with their content, adding proper quotation marks. That is,
**pandoc-quotes.lua** pushes quotations from the syntax of a document's
representation into its semantics. That being so, you should *not* 
use **pandoc-quotes.lua** with output formats that represent quotes
syntactically (e.g., HTML, LaTeX, ConTexT). Moroever, filters running after
**pandoc-quotes** won't recognise quotes. So, it should be the last or
one of the last filters you apply.

Support for quotation marks of different languages is certainly incomplete
and likely erroneous. See <https://github.com/odkr/pandoc-quotes.lua> if
you'd like to help with this.

**pandoc-quotes.lua** is Unicode-agnostic.


# SEE ALSO

pandoc(1)
