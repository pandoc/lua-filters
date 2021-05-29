# pandoc-doi2cite
This pandoc lua filiter helps users to insert references in a document
with using DOI(Digital Object Identifier) tags. With this filter, users
do not need to make bibtex file by themselves. Instead, the filter
automatically generate .bib file from the DOI tags, and convert the DOI
tags into citation keys available by --citeproc.

<img src="https://user-images.githubusercontent.com/30950088/117561410-87ec5d00-b0d1-11eb-88be-931f3158ec44.png" width="960">

What the filter do are as follows:
1.  Search citations with DOI tags in the document
2.  Search corresponding bibtex data from `__from_DOI.bib` file
3.  If not found, get bibtex data of the DOI from
    http://api.crossref.org
4.  Add reference data to `__from_DOI.bib` file
5.  Check duplications of reference keys
6.  Replace DOI tags to the correspoinding citation keys

# Prerequisites
-   Pandoc version 2.0 or newer
-   This filter does not need any external dependencies
-   This filter should be executed before `pandoc-crossref` or
    `--citeproc`

# DOI tags
Following DOI tags can be used:
-   @https://doi.org/
-   @doi.org/
-   @DOI:
-   @doi:

The first one (@https://doi.org/) may be the most useful because it is
same as the accessible URL.

# YAML header
The file **name** of the auto-generated bibliography file **MUST** be
`__from_DOI.bib`, but the **place** of the file can be changed (e.g. 
`'./refs/__from_DOI.bib'` or `'refs\\__from_DOI.bib'` for Windows). Yo
u can designate the filepath in the document yaml header. The yaml key
 is `bibliography`, which is also used by --citeproc.


# Example

example1.md:

    ---
    bibliography:
      - 'my_refs.bib'
      - '__from_DOI.bib'
    ---

    # Introduction
    The Laemmli system is one of the most widely used gel systems for the separation of proteins.[@LAEMMLI_1970]
    By the way, Einstein is genius.[@https://doi.org/10.1002/andp.19053220607; @doi.org/10.1002/andp.19053220806; @doi:10.1002/andp.19053221004]

Example command 1 (.md -\> .md)

``` {.sh}
pandoc --lua-filter=doi2cite.lua --wrap=preserve -s example1.md -o expected1.md
```

Example command 2 (.md -\> .pdf with
[ACS](https://pubs.acs.org/journal/jacsat) style):

``` {.sh}
pandoc --lua-filter=doi2cite.lua --filter=pandoc-crossref --citeproc --csl=sample1.csl -s example1.md -o expected1.pdf
```

Example result

![expected1](https://user-images.githubusercontent.com/30950088/119964566-4d952200-bfe4-11eb-90d9-ed2366c639e8.png)
