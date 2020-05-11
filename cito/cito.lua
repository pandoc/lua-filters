-- Copyright © 2017–2020 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local _version = '1.0.0'
local properties_and_aliases = {
  agrees_with = {
    'agree_with'
  },
  citation = {
  },
  cites = {
  },
  cites_as_authority = {
    'as_authority',
    'authority'
  },
  cites_as_data_source = {
    "as_data_source",
    "data_source"
  },
  cites_as_evidence = {
    'as_evidence',
    'evidence'
  },
  cites_as_metadata_document = {
    'as_metadata_document',
    'metadata_document',
    'metadata'
  },
  cites_as_recommended_reading = {
    'as_recommended_reading',
    'recommended_reading'
  },
  disagrees_with = {
    'disagree',
    'disagrees'
  },
  disputes = {
  },
  documents = {
  },
  extends = {
  },
  includes_excerpt_from = {
    'excerpt',
    'excerpt_from'
  },
  includes_quotation_from = {
    'quotation',
    'quotation_from'
  },
  obtains_background_from = {
    'background',
    'background_from'
  },
  refutes = {
  },
  replies_to = {
  },
  updates = {
  },
  uses_data_from = {
    'data',
    'data_from'
  },
  uses_method_in = {
    'method',
    'method_in'
  },
}

local default_cito_property = 'citation'

--- Map from cito aliases to the actual cito property.
local properties_by_alias = {}
for property, aliases in pairs(properties_and_aliases) do
  -- every property is an alias for itself
  properties_by_alias[property] = property
  for _, alias in pairs(aliases) do
    properties_by_alias[alias] = property
  end
end

--- Split citation ID into cito property and the actual citation ID. If
--- the ID does not seem to contain a CiTO property, the
--- `default_cito_property` will be returned, together with the
--- unchanged input ID.
local function split_cito_from_id (citation_id)
  local pattern = '^(.+):(.+)$'
  local prop_alias, split_citation_id = citation_id:match(pattern)

  if properties_by_alias[prop_alias] then
    return properties_by_alias[prop_alias], split_citation_id
  end

  return default_cito_property, citation_id
end

--- Citations by CiTO properties.
local function store_cito (cito_cites, prop, cite_id)
  if not prop then
    return
  end
  if not cito_cites[prop] then
    cito_cites[prop] = {}
  end
  table.insert(cito_cites[prop], cite_id)
end

--- Returns a Cite filter function which extracts CiTO information and
--- add it to the given collection table.
local function extract_cito (cito_cites)
  return function (cite)
    for k, citation in pairs(cite.citations) do
      local cito_prop, cite_id = split_cito_from_id(citation.id)
      store_cito(cito_cites, cito_prop, cite_id)
      citation.id = cite_id
    end
    return cite
  end
end

--- Lists of citation IDs, indexed by CiTO properties.
local citations_by_property = {}

return {
  {
    Cite = extract_cito(citations_by_property)
  },
  {
    Meta = function (meta)
      meta.cito_cites = citations_by_property
      return meta
    end
  }
}
