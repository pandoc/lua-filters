# include-meta

This filter adds the meta-data from one or more external YAML files to 
the metadata of the document.

This allows defining frequently needed sets of meta-data in external files
and reusing them.

In contrast to the `--metadata-file` option of Pandoc, this filter allows specifying the set(s) of meta-data in the actual document header, which is 
more transparent than e.g. hiding them in a make script.

## Specifying a YAML File to be included

Simply add the `include-meta` directive to the document header, like so:

    ---
    title: My document
    author: Joe Doe
    include-meta: defaults.yaml
    ...

Multiple files can be specified by using a list:

    ---
    title: My document
    author: Joe Doe
    include-meta: 
      - defaults.yaml
      - moredefaults.yaml
    ...

## Priority Rules

The metadata from the external YAML files will be processed in the order of (1) the statements in the document's YAML header block and (2) the position of the file in the list.

   ---
    title: My document
    author: Joe Doe
    include-meta: 
      - first.yaml
      - second.yaml
    include-meta: third.yaml
    include-meta: 
      - fourth.yaml
      - fifth.yaml
    header-includes:
      - \setbeamertemplate{footline}[page number]
    ...

The **metadata in the YAML header of the document** is processed **at the very end** (i.e. with the highest priority).

The metadata from all referenced YAML files and the YAML header in the document **is combined as follows:**

- duplicates are ignored,
- `title` and `date` are replaced by the value in the source with the highest priority (the document or the last YAML file in the list),
- `author`, `header-includes` and `bibliography` values are joined into a combined list, and
- values from all other properties are taken from the source with the highest priority (e.g. set according to the YAML in the document).

For instance, if you specify one author in the the first YAML and another one in the second, the final meta-data will be a list of both. The order of the list will represent the order of the processing (see above).

**Note:** The merging rules and code are based on a [Github Issue discussion](https://github.com/jgm/pandoc/issues/3115#issuecomment-294506221).

The exact relationship between metadata from the document and the sum of the external YAML files is still evolving. I might add a mechanism for specifying the priority of e.g. the document settings. 


## Work in Progress

This filter is work in progress.

