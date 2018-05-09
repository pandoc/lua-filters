# cito

This filter extracts optional CiTO (Citation Typing Ontology)
information from citations and stores the information in the
document's metadata. The extracted info is intended to be used in
combination with other filters, templates, or custom writers. It
is mandatory to run pandoc-citeproc *after* this filter if CiTO
data is embedded in the document; otherwise pandoc-citeproc will
interpret CiTO properties as part of the citation ID.

## Using the Citation Typing Ontology

The [citation typing ontology] (CiTO) allows authors to specify the
reason a citation is given. This is helpful for the authors and
their co-authors, and furthermore adds data that can be used by
readers to search and navigate relevant publications.

A CiTO annotation must come before the citation key and be
followed by a colon. E.g., `@method_in:towbin_1979` signifies
that the citation with ID *towbin_1979* is cited because the
method described in that paper has been used in the paper at
hand.

[citation typing ontology]: http://purl.org/spar/cito

## Recognized CiTO properties

Below is the list of CiTO properties recognized by the filter,
together with the aliases that can be used as shorthands.

- agrees_with
  - agree_with
- citation
- cites
- cites_as_authority
  - as_authority
  - authority
- cites_as_data_source
- cites_as_evidence
  - as_evidence
  - evidence
- cites_as_metadata_document
  - as_metadata_document
  - metadata_document
  - metadata
- cites_as_recommended_reading
  - as_recommended_reading
  - recommended_reading
- disagrees_with
  - disagree
  - disagrees
- disputes
- documents
- extends
- includes_excerpt_from
  - excerpt
  - excerpt_from
- includes_quotation_from
  - quotation
  - quotation_from
- obtains_background_from
  - background
  - background_from
- refutes
- replies_to
- updates
- uses_data_from
  - data
  - data_from
- uses_method_in
  - method
  - method_in

## References

This approach was described in <https://doi.org/10.7717/peerj-cs.112>.
