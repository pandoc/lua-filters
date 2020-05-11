# section-refs

This filter allows the user to put bibliographies at the end of each
section, containing only those references in the section. It works on
the output of `pandoc-citeproc`, and so must be run after
`pandoc-citeproc`. For example:

~~~
pandoc input.md -F pandoc-citeproc --lua-filter section-refs.lua
~~~

It allows curstomization through two metadata fields:
`reference-section-title` and `section-refs-level` (default 1). The
`section-refs-level` variable controls what level the biblography will
occur at the end of. The header of the generated references section will
be one level higher than `section-refs-level` (so if it occurs at the
end of a level-1 section, it will receive a level-2 header, and so on).

This filter requires pandoc version >= 2.1.
