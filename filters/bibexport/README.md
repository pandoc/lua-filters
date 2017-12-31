# bibexport

Export all cited references into a single bibtex file. This is
most useful when writing collaboratively while using a large,
private bibtex collection. Using the bibexport filter allows to
create a reduced bibtex file suitable for sharing with
collaborators.

## Prerequisites

This filter expects the `bibexport` executable to be installed
and in the user's PATH.

## Usage

The filter runs `bibexport` on a temporary *aux* file, creating
the file *bibexport.bib* on success. The name of the temporary
*.aux* file can be set via the `auxfile` meta value; if no value
is specified, *bibexport.aux* will be used as filename.

Please note that `bibexport` prints messages to stdout. Pandoc
should be called with the `-o` or `--output` option instead of
redirecting stdout to a file. E.g.

    pandoc --lua-filter=bibexport.lua article.md -o article.html

or, when the filter is called in a one-off fashion

    pandoc --lua-filter=bibexport.lua article.md -o /dev/null
    

