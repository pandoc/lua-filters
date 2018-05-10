# abstract-to-meta

This moves a document's abstract from the main text into the
metadata. Metadata elements usually allow for finer placement
control in the final output, but writing body text is easier and
more natural.

## Defining an Abstract

A document abstract can either be put directly in the document
metadata, for example by inserting an *abstract* attribute into a
YAML block.

    ---
    abstract: |
      Place abstract here.

      Multiple paragraphs are possible.
    ---

The additional indentation and formatting requirements in YAML
headers can be confusing or annoying for authors. It is hence
preferable to allow abstracts be written as normal sections.

    # Abstract

    Place abstract here.

    Multiple paragraphs are possible.

This filter turns the latter into the former by looking for a
top-level header whose ID is `abstract`. Pandoc auto-creates IDs
based on header contents, so a header titled *Abstract* will
satisfy this condition.^[1]

[1]: This requires the `auto_identifier` extension. It is
     enabled by default.
