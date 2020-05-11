---
title: PANDOC-ZOTXT.LUA(1)
author: Odin Kroeger
date: May 2, 2019
---

# NAME

pandoc-zotxt.lua - Looks up sources in Zotero


# SYNOPSIS

**pandoc** **--lua-filter** *pandoc-zotxt.lua* **-F** *pandoc-citeproc*


# DESCRIPTION

**pandoc-zotxt.lua** looks up sources of citations in Zotero and adds
them either to a document's `references` metadata field or to its
bibliography, where **pandoc-citeproc** can pick them up.

You cite your sources using so-called "easy citekeys" (provided by *zotxt*) or
"Better BibTeX Citation Keys" (provided by *Better BibTeX for Zotero*) and
then tell  **pandoc** to run **pandoc-zotxt.lua** before **pandoc-citeproc**.
That's all all there is to it. (See the documentation of *zotxt* and 
*Better BibTeX for Zotero* respectively for details.)

You can also use **pandoc-zotxt.lua** to manage a bibliography file. This is
usually a lot faster. Simply set the `zotero-bibliography` metadata field
to a filename. **pandoc-zotxt.lua** will then add the sources you cite to that
file, rather than to the `references` metadata field. It will also add
that file to the document's `bibliography` metadata field, so that
**pandoc-zotxt.lua** picks it up. The biblography is stored in CSL JSON,
so the filename must end in ".json".

**pandoc-zotxt.lua** takes relative filenames to be relative to the directory
of the first input file you pass to **pandoc** or, if you don't pass any input
files, as relative to the current working directory.

Note, **pandoc-zotxt.lua** only ever *adds* sources to bibliography files.
It doesn't update or delete them. To update your bibliography file,
delete it. **pandoc-zotxt.lua** will then regenerate it from scratch.


# CAVEATS

**pandoc-zotxt.lua** is Unicode-agnostic.


# SEE ALSO

pandoc(1), pandoc-citeproc(1)
