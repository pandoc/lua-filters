# Non-breakable space filter

This filter replaces regular spaces with non-breakable spaces according to 
predefined conditions.

Rules for space replacement are defined for two languages: English and Czech
(default is English) in `prefixes` tables. Also, non-breakable spaces are
inserted in front of dashes and in front of numbers. Rules for inserting 
non-breakable spaces in English are not as firm as in authors native language 
(Czech), but some typographic conventions suggest to insert non-breakable space
after words: "I", "the", "The", "a", "A". Any suggestions regarding improvement 
of English support in this filter are highly welcome.
Some extra effort is taken in detecting these patterns in *not-fully* parsed
strings (for example, if this filter is used after some macro replacing 
filter).

In this regard this filter functions similarly like TeX `vlna` preprocessor
(only Czech) or LuaTeX `luavlna` package (international).

The default settings can be changed easily by user customization in filter file
`pandocVlna.lua` by changing contents of `prefixes` or `dashes` tables.

Currently supported formats are:

* LaTeX a ConTeXt
* Open Office Document
* MS Word
* HTML

For other formats filter defaults to insert escaped Unicode sequence `\u{a0}`.

**NOTE**: Using this filter increases strain on line-breaking patterns. Whenever 
possible, consider allowing hyphenation.
