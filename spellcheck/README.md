# spellcheck

This filter checks the spelling of words in the body of the
document (omitting metadata).  The external program `aspell` is
used for the checking, and must be present in the path.

Why use this instead of just running `aspell` on the
document's source?  Because this filter is sensitive to
the semantics of the document in ways that `aspell` is
not:

- Material in code spans, raw HTML, URLs in links,
  and math is not spell-checked, eliminating a big
  class of false positives.

- The filter is sensitive to the `lang` specified in
  the document's metadata; this will be treated as the
  default language for the document.

- It is also sensitive to `lang` attributes on native
  divs and spans. Thus, for example, in an English
  document, `[chevaux]{lang=fr}` will not be registered
  as a spelling error.

To run it,

    pandoc --lua-filter spellcheck.lua sample.md

A list of misspelled words (or at any rate, words not
in the appropriate dictionary) will be printed to stdout.
If the word is in a div or span with a non-default `lang`
attribute, the relevant language will be indicated in
brackets after the word, separated by a tab.

To add words to the list for a language, you can add files
with names `.aspell.LANG.pws` in your home directory.  Example:

```
% cat ~/.aspell.en.pws
personal_ws-1.1 en 0
goopy
```
