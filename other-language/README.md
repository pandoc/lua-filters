# other-language for TeX code blocks

This filter ensures that the raw content such a code blocks are enclosed with
the english language so any typographic rules existing the base language are
not applied. It was conceived with French in mind but surely can be useful to
other languages.

## Using the filter

For it to do anything, the main document language should be something else than
`en`, e.g. `fr`.

```yaml
---
lang: fr
---
```

Which will produce

```latex
\documentclass[french,]{article}

% ...

\usepackage[shorthands=off,english,main=french]{babel}

% ...

\usepackage{polyglossia}
\setmainlanguage[]{french}
\setotherlanguage[]{english}
```

Then any code block, or inline code will be surrounded with the
`\begin{otherlanguage}{english}` and `\end{otherlanguage}`. It will be killing
off any typographic changes such as the insecable space before a colon.
