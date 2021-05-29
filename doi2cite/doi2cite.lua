--------------------------------------------------------------------------------
-- Copyright © 2021 Takuro Hosomi
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Global variables --
--------------------------------------------------------------------------------
base_url = "http://api.crossref.org"
mailto = "pandoc.doi2cite@gmail.com"
bibname = "__from_DOI.bib"
key_list = {};
doi_key_map = {};
doi_entry_map = {};
error_strs = {};
error_strs["Resource not found."] = 404
error_strs["No acceptable resource available."] = 406
error_strs["<html><body><h1>503 Service Unavailable</h1>\n"
        .."No server is available to handle this request.\n"
        .."</body></html>"] = 503


--------------------------------------------------------------------------------
-- Pandoc Functions --
--------------------------------------------------------------------------------
-- Get bibliography filepath from yaml metadata
function Meta(m)
    local bib_data = m.bibliography
    local bibpaths = get_paths_from(bib_data)
    bibpath = find_filepath(bibname, bibpaths)
    bibpath = verify_path(bibpath)
    local f = io.open(bibpath, "r")
    if f then
        entries_str = f:read('*all')
        if entries_str then
            doi_entry_map = get_doi_entry_map(entries_str)
            doi_key_map = get_doi_key_map(entries_str)
            for doi,key in pairs(doi_key_map) do
                key_list[key] = true
            end
        end
        f:close()
    else
        make_new_file(bibpath)
    end
end

-- Get bibtex data of doi-based citation.id and make bibliography.
-- Then, replace "citation.id"
function Cite(c)
    for _, citation in pairs(c.citations) do
        local id = citation.id:gsub('%s+', ''):gsub('%%2F', '/')
        if id:sub(1,16) == "https://doi.org/" then
            doi = id:sub(17):lower()
        elseif id:sub(1,8) == "doi.org/" then
            doi = id:sub(9):lower()
        elseif id:sub(1,4) == "DOI:" or id:sub(1,4) == "doi:" then
            doi = id:sub(5):lower()
        else
            doi = nil
        end
        if doi then
            if doi_key_map[doi] then
                citation.id = doi_key_map[doi]
            else
                local entry_str = get_bibentry(doi)
                if entry_str == nil or error_strs[entry_str] then
                    print("Failed to get ref from DOI: " .. doi)
                else
                    entry_str = tex2raw(entry_str)
                    local entry_key = get_entrykey(entry_str)
                    if key_list[entry_key] then
                        entry_key = entry_key.."_"..doi
                        entry_str = replace_entrykey(entry_str, entry_key)
                    end
                    key_list[entry_key] = true
                    doi_key_map[doi] = entry_key
                    citation.id = entry_key
                    local f = io.open(bibpath, "a+")
                    if f then
                        f:write(entry_str .. "\n")
                        f:close()
                    else
                        error("Unable to open file: "..bibpath)
                    end
                end                
            end
        end
    end
    return c
end


--------------------------------------------------------------------------------
-- Common Functions --
--------------------------------------------------------------------------------
-- Get bib of DOI from http://api.crossref.org
function get_bibentry(doi)
    local entry_str = doi_entry_map[doi]
    if entry_str == nil then
        print("Request DOI: " .. doi)
        local url = base_url.."/works/"
            ..doi.."/transform/application/x-bibtex"
            .."?mailto="..mailto
        mt, entry_str = pandoc.mediabag.fetch(url)
    end
    return entry_str
end

-- Extract designated filepaths from 1 or 2 dimensional metadata
function get_paths_from(metadata)
    local filepaths = {};
    if metadata then
        if metadata[1].text then
            filepaths[metadata[1].text] = true
        elseif type(metadata) == "table" then
            for _, datum in pairs(metadata) do
                if datum[1] then
                    if datum[1].text then
                        filepaths[datum[1].text] = true
                    end
                end
            end
        end
    end
    return filepaths    
end

-- Extract filename and dirname from a given a path 
function split_path(filepath)
    local delim = nil
    local len = filepath:len()
    local reversed = filepath:reverse()
    if filepath:find("/") then
        delim = "/"
    elseif filepath:find([[\]]) then
        delim = [[\]]
    else
        return {filename = filepath, dirname = nil}
    end
    local pos = reversed:find(delim)
    local dirname = filepath:sub(1, len - pos)
    local filename = reversed:sub(1, pos - 1):reverse()
    return {filename = filename, dirname = dirname}
end

-- Find bibname in a given filepath list and return the filepath if found 
function find_filepath(filename, filepaths)
    for path, _ in pairs(filepaths) do
        local filename = split_path(path)["filename"]
        if filename == bibname then
            return path
        end
    end
    return nil
end

-- Make some TeX descriptions processable by citeproc
function tex2raw(string)
    local symbols = {};
    symbols["{\textendash}"] = "–"
    symbols["{\textemdash}"] = "—"
    symbols["{\textquoteright}"] = "’"
    symbols["{\textquoteleft}"] = "‘"
    for tex, raw in pairs(symbols) do
        local string = string:gsub(tex, raw)
    end
    return string
end

-- get bibtex entry key from bibtex entry string
function get_entrykey(entry_string)
    local key = entry_string:match('@%w+{(.-),') or ''
    return key
end

-- get bibtex entry doi from bibtex entry string
function get_entrydoi(entry_string)
    local doi = entry_string:match('doi%s*=%s*["{]*(.-)["}],?') or ''
    return doi
end

-- Replace entry key of "entry_string" to newkey
function replace_entrykey(entry_string, newkey)
    entry_string = entry_string:gsub('(@%w+{).-(,)', '%1'..newkey..'%2')
    return entry_string    
end 

-- Make hashmap which key = DOI, value = bibtex entry string
function get_doi_entry_map(bibtex_string)
    local entries = {};
    for entry_str in bibtex_string:gmatch('@.-\n}\n') do
      local doi = get_entrydoi(entry_str)
      entries[doi] = entry_str
    end
    return entries
end

-- Make hashmap which key = DOI, value = bibtex key string
function get_doi_key_map(bibtex_string)
    local keys = {};
    for entry_str in bibtex_string:gmatch('@.-\n}\n') do
      local doi = get_entrydoi(entry_str)
      local key = get_entrykey(entry_str)
      keys[doi] = key
    end
    return keys
end

-- function to make directories and files
function make_new_file(filepath)
    if filepath then
        print(filepath)
        local filename = split_path(filepath)["filename"]
        local dirname = split_path(filepath)["dirname"]
        if filename then
            os.execute("mkdir "..dirname)
        end
        f = io.open(filepath, "w")
        if f then
            f:close()
        else
            error("Unable to make bibtex file: "..bibpath..".\n"
            .."This error may come from the missing directory. \n"
            )
        end
    end
end

-- Verify that the given filepath is correct.
-- Catch common Pandoc user mistakes about Windows-formatted filepath.
function verify_path(bibpath)
    if bibpath == nil then
        print("[WARNING] doi2cite: "
            .."The given file path is incorrect or empty. "
            .."In Windows-formatted filepath, Pandoc recognizes "
            .."double backslash ("..[[\\]]..") as the delimiters."
        )
        return "__from_DOI.bib"
    else
        return bibpath
    end
end

--------------------------------------------------------------------------------
-- The main function --
--------------------------------------------------------------------------------
return {
    { Meta = Meta },
    { Cite = Cite }
}
