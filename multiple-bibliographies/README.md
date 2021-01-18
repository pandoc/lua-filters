# multiple-bibliographies

This filter allows to create multiple bibliographies using
`pandoc-citeproc`/`citeproc`. The content of each bibliography is controlled
via YAML values and the file in which a bibliographic entry is
specified.

## Usage

Instead of using the usual *bibliography* metadata field, all
bibliographies must be defined via a separate field of the scheme
*bibliographyX*, e.g.

    ---
    bibliography_main: main-bibliography.bib
    bibliography_software: software.bib
    ---

The placement of bibliographies is controlled via special divs.

    # References
    
    ::: {#refs_main}
    :::
    
    # Software
    
    ::: {#refs_software}
    :::

Each refsX div should have a matching bibliographyX entry in the
header. These divs are filled with citations from the respective
bib-file.
