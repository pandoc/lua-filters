# include-meta

This filter adds the meta-data from one or more external YAML files to 
the metadata of the document.

This allows defining frequently needed sets of meta-data in external files
and reusing them.

In contrast to the `--metadata-file` option of Pandoc, this filter allows specifying the set(s) of meta-data in the actual document header, which is 
more transparent than hiding them in a make script.

## Specifying a YAML File to be included

Simply add the `include-meta` directive to the document header, like so:

    ---
    title: My document
    author: Joe Doe
    include-meta: defaults.yaml
    header-includes:
      - \setbeamertemplate{footline}[page number]
    ...

Multiple files can be specified, either by using a list

    ---
    title: My document
    author: Joe Doe
    include-meta: 
      - defaults.yaml
      - moredefaults.yaml
    header-includes:
      - \setbeamertemplate{footline}[page number]
    ...

or by multiple `include-meta` directives:

    ---
    title: My document
    author: Joe Doe
    include-meta: defaults.yaml
    include-meta: moredefaults.yaml
    header-includes:
      - \setbeamertemplate{footline}[page number]
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

The metadata from all referenced YAML files **is merged,** except for duplicates. For instance, if you specify one author in the the first YAML and another one in the second, the final meta-data will be a list of both. The order of the list will represent the order of the processing (see above).

**Note:** This can lead to unexpected results if a single value is expected. But since there is no easy way of specifying detailed merging rules, the best is to modularize the YAML files properly in order to avoid such conflicts.

The exact relationship between metadata from the document and the sum of the external YAML files is to decided. It will likely follow the same mechanism, but this means that you can e.g. not override any meta-data from the included YAML files (logo path, document settings, etc.).

## Work in Progress

This filter is work in progress **AND NOT YET READY FOR USE!**.

