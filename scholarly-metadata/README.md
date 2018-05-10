# scholarly-metadata

The filter turns metadata entries for authors and their
affiliations into a canonical form. This allows users to
conveniently declare document authors and their affiliations,
while making it possible to rely on default object metadata
structures when using the data in other filters or when accessing
the data from custom templates.


## Canonical format for authors and affiliations

Authors and affiliations entries are treated as *named objects*.
All named objects will have an ID and a name, i.e. they are
metadata objects with *at least* those two keys:

    - id: namedObjectExample
      name: Example for a named object.

The filter converts the *author* and *institute* metadata fields
into lists of named objects.

E.g., the following YAML data

    author:
      - Jane Doe:
          email: 'jane.doe@example.edu'
      - John Q. Doe


will be transformed into

    author:
    - email: 'jane.doe\@example.edu'
      id: Jane Doe
      name: Jane Doe
    - id: 'John Q. Doe'
      name: 'John Q. Doe'
      
Internally, `id` will be a simple string, while `name` is of type
`MetaInlines`.
      

## Referencing affiliations

Author affiliations are a common feature of scholarly
publications. It is possible to add institutes to each author
object. Three methods of doing this are supported.

1.  **Referencing institutes by list index**: affiliations can be
    listed in the *institute* metadata field and then referenced
    by using the numerical index:
    
        institute:
          - Acme Corporation
          - Federation of Planets
        author:
          - Jane Doe:
              institute: [1, 2]
          - John Q. Doe:
              institute: [2]
        
    This is also the canonical representation used to keep track
    of author affiliations.

2.  **Referencing institutes by ID**: using numerical indices is
    error prone and difficult to maintain when adding or removing
    authors or affilications. It is hence possible to use IDs
    instead:

        institute:
          - acme: Acme Corporation
          - federation: Federation of Planets
        author:
          - Jane Doe:
              institute: [acme, federation]
          - John Q. Doe:
              institute: [federation]

3.  **Adding institute as an attribute**: sometimes it might be
    more convenient to give an affiliation directly in the
    author's YAML object. Those objects can still be referenced
    by ID from authors listed below such entry.
    
        author:
          - Jane Doe:
              institute:
               - Acme Cooproration
               - federation: Federation of Planets
          - John Q. Doe:
              institute: [federation]
