# Non-breakable space filter

This filter replaces regular spaces with non-breakable spaces according to 
predefined conditions. Currently, this filter replaces regular spaces with
unbreakable ones after one-letter words (prefixes and conjunctions):
'a', 'i', 'k', 'o', 's', 'u', 'v', 'z'; and theyre uppercase variant. Also
inserts non-breakable spaces in front of en-dashes and in front of numbers.
Some extra effort is taken in detecting these patterns in *not-fully* parsed
strings (for example, if this filter is used after some macro replacing 
filter).

In this regard this filter functions similarly like TeX `vlna` preprocessor
or LuaTeX `luavlna` package.

The default settings are conformant to Czech typography rules, but these can
be changed easily by user customization in filter file `nonbreakablespace.lua`
by changing contents of `prefixes` or `dashes` tables.

Currently supported formats are:

* LaTeX a ConTeXt
* Open Office Document
* MS Word
* HTML

**NOTE**: Using this filter increases strain on line-breaking patterns. Whenever 
possible, consider allowing hyphenation.
