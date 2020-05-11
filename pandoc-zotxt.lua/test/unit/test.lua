--- test.lua - A fake Pandoc filter that runs units for for pandoc-zotxt.lua.
--
-- # SYNOPSIS
-- 
--      pandoc --lua-filter test.lua -o /dev/null FILE
-- 
-- 
-- # DESCRIPTION
-- 
-- A fake Pandoc filter that runs units for for pandoc-zotxt.lua. 
-- Which tests are run is goverend by the `tests` metadata field in FILE.
-- This field is passed to lu.LuaUnit.run. If `tests` is not set,
-- runs all tests.
--
--
-- # SEE ALSO
--
-- <https://luaunit.readthedocs.io/>
--
-- # AUTHOR
--
-- Copyright 2019 Odin Kroeger
--
--
-- # LICENSE
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
--
-- @script test.lua
-- @author Odin Kroeger
-- @copyright 2018, 2019 Odin Kroeger
-- @license MIT


-- # SHORTHANDS

local popen = io.popen
local time = os.time
local execute = os.execute
local exit = os.exit
local concat = table.concat
local unpack = table.unpack
local format = string.format

local stringify = pandoc.utils.stringify


-- # LIBRARIES

local text = require 'text'
local sub = text.sub

--- The path seperator of the operating system
local PATH_SEP = sub(package.config, 1, 1)

do
    local split_expr = '(.-' .. PATH_SEP .. '?)([^' .. PATH_SEP .. ']-)$'
    local san_exprs = {{PATH_SEP .. '%.' .. PATH_SEP, PATH_SEP},
        {PATH_SEP .. '+', PATH_SEP}, {'^%.' .. PATH_SEP, ''}}
    
    --- Splits a file's path into a directory and a filename part.
    --
    -- @tparam string path The path to the file.
    -- @treturn string The file's path.
    -- @treturn string The file's name.
    --
    -- This function makes an educated guess given the string it's passed.
    -- It doesn't look at the filesystem. The guess is educated enough though.
    function split_path (path)
        assert(path ~= '', 'path is the empty string')
        for _, s in ipairs(san_exprs) do path = path:gsub(unpack(s)) end
        local dir, fname = path:match(split_expr)
        dir = dir:gsub('(.)' .. PATH_SEP .. '$', '%1')
        if dir == '' then dir = '.' end
        if fname == '' then fname = '.' end
        return dir, fname
    end
end


--- The directory of the script. 
local SCRIPT_DIR = split_path(PANDOC_SCRIPT_FILE)

--- The directory of the test suite. 
local TEST_DIR = concat({SCRIPT_DIR, '..'}, PATH_SEP)

--- The test suite's data directory.
local DATA_DIR = concat({TEST_DIR, 'data'}, PATH_SEP)

--- The test suite's temporary directory.
local TMP_DIR = concat({TEST_DIR, 'tmp'}, PATH_SEP)

--- The repository directory.
local REPO_DIR = concat({TEST_DIR, '..'}, PATH_SEP)

package.path = package.path .. ';' .. 
    concat({REPO_DIR, 'share', 'lua', '5.3', '?.lua'}, PATH_SEP)

local lu = require 'luaunit'
local M = require 'pandoc-zotxt'


-- # CONSTANTS

--- Bibliographic data in CSL to compare retrieved data to.
NORM_SOURCE = {
    id = 'haslanger:2012resisting', type = 'book',
    author = {{family = 'Haslanger', given = 'Sally'}},
    title = 'Resisting Reality: Social Construction and Social Critique',
    publisher = 'Oxford University Press', ['publisher-place'] = 'Oxford',
    issued = {['date-parts'] = {{'2012'}}},
    ['title-short'] = 'Resisting Reality',
    ISBN = '978-0-19-989262-4'
}

--- Configuration options.
--
-- `run` overrides these defaults.
--
-- @table
CONFIG = {}


-- # FUNCTIONS

--- Copies tables recursively.
--
-- Handles metatables, recursive structures, tables as keys, and
-- avoids the `__pairs` and `__newindex` metamethods.
-- Copies are deep.
--
-- @param orig The original.
--
-- @return A copy.
--
-- @usage
--      > x = {1, 2, 3}
--      > y = {x, 4}
--      > c = copy(y)
--      > table.insert(x, 4)
--      > table.unpack(c[1])
--      1       2       3
function copy (data, s)
    -- Borrows from:
    -- * <https://gist.github.com/tylerneylon/81333721109155b2d244>
    -- * <http://lua-users.org/wiki/CopyTable>
    if type(data) ~= 'table' then return data end
    if s and s[data] then return s[data] end
    local copy = copy
    local res = setmetatable({}, getmetatable(data))
    s = s or {}
    s[data] = res
    for k, v in next, data, nil do
        rawset(res, copy(k, s), copy(v, s))
    end
    return res
end


-- # TESTS

test_core = {}

function test_core:test_split_path ()
    local invalid_inputs = {nil, false, 0, '', {}, function () end}
    
    for _, v in ipairs(invalid_inputs) do
        lu.assert_error(M.split_path, v)
    end

    local tests = {
        ['.']                   = {'.',         '.' },
        ['..']                  = {'.',         '..'},
        ['/']                   = {'/',         '.' },
        ['//']                  = {'/',         '.' },
        ['/////////']           = {'/',         '.' },
        ['/.//////']            = {'/',         '.' },
        ['/.////.//']           = {'/',         '.' },
        ['/.//..//.//']         = {'/..',       '.' },
        ['/.//..//.//../']      = {'/../..',    '.' },
        ['a']                   = {'.',         'a' },
        ['./a']                 = {'.',         'a' },
        ['../a']                = {'..',        'a' },
        ['/a']                  = {'/',         'a' },
        ['//a']                 = {'/',         'a' },
        ['//////////a']         = {'/',         'a' },
        ['/.//////a']           = {'/',         'a' },
        ['/.////.//a']          = {'/',         'a' },
        ['/.//..//.//a']        = {'/..',       'a' },
        ['/.//..//.//../a']     = {'/../..',    'a' },
        ['a/b']                 = {'a',         'b' },
        ['./a/b']               = {'a',         'b' },
        ['../a/b']              = {'../a',      'b' },
        ['/a/b']                = {'/a',        'b' },
        ['//a/b']               = {'/a',        'b' },
        ['///////a/b']          = {'/a',        'b' },
        ['/.//////a/b']         = {'/a',        'b' },
        ['/.////.//a/b']        = {'/a',        'b' },
        ['/.//..//.//a/b']      = {'/../a',     'b' },
        ['/.//..//.//../a/b']   = {'/../../a',  'b' },
        ['/a/b/c/d']            = {'/a/b/c',    'd' },
        ['a/b/c/d']             = {'a/b/c',     'd' },
        ['a/../.././c/d']       = {'a/../../c', 'd' }
}
    
    for k, v in pairs(tests) do
        local dir, fname = M.split_path(k)
        lu.assert_equals(dir, v[1])
        lu.assert_equals(fname, v[2])
    end
end

do    
    function test_core:test_map ()
        local function base (x) return x end
        local function successor (x) return x + 1 end
        
        local invalid_inputs = {nil, false, 0, '', {}}
        for _, a in ipairs(invalid_inputs) do
            for _, b in ipairs({nil, false, 0, '', base}) do
                lu.assert_error(M.map, a, b)
            end
        end

        local tests = {
            [base]      = {[{}] = {}, [{1}] = {1}, [{1, 2, 3}] = {1, 2, 3}},
            [successor] = {[{}] = {}, [{1}] = {2}, [{1, 2, 3}] = {2, 3, 4}},
        }

        for func, values in ipairs(tests) do
            for k, v in pairs(values) do
                lu.assert_equals(M.map(func, k), v)
            end
        end
    end
end

function test_core:test_get_position ()
    local invalid_inputs = {nil, false, 0, 'x', function () end}
    for _, v in ipairs(invalid_inputs) do
        lu.assert_error(M.get_position, nil, v)
    end
    
    local tests = {
        [{nil, {}}]         = nil,
        [{nil, {1, 2, 3}}]  = nil,
        [{2, {1}}]          = nil,
        [{1, {1}}]          = 1,
        [{1, {1, 2, 3}}]    = 1,
        [{2, {1, 2, 3}}]    = 2,
        [{3, {1, 2, 3}}]    = 3
    }
    
    for k, v in pairs(tests) do
        lu.assert_equals(M.get_position(unpack(k)), v)
    end
end

function test_core:test_get_input_directory ()    
    lu.assert_equals(M.get_input_directory(), PATH_SEP .. 'dev')

end


function test_core:test_is_path_absolute ()
    local original_path_sep = M.PATH_SEP
    lu.assert_error(M.is_path_absolute)
    
    M.PATH_SEP = '\\'
    local tests = {
        ['\\']          = true,
        ['C:\\']        = true,
        ['[:\\']        = true,
        ['\\test']      = true,
        ['test']        = false,
        ['test\\test']  = false,
        ['/']           = false,
        ['/test']       = false,
        ['test/test']   = false
    }    

    for k, v in pairs(tests) do
        lu.assert_equals(M.is_path_absolute(k), v)
    end

    M.PATH_SEP = '/'
    local tests = {
        ['\\']          = false,
        ['C:\\']        = false,
        ['[:\\']        = false,
        ['\\test']      = false,
        ['test']        = false,
        ['test\\test']  = false,
        ['/']           = true,
        ['/test']       = true,
        ['test/test']   = false
    }    

    for k, v in pairs(tests) do
        lu.assert_equals(M.is_path_absolute(k), v)
    end
    
    M.PATH_SEP = original_path_sep
end

function test_core:test_convert_numbers_to_strings ()
    local a = {}
    a.a = a
    lu.assert_error(M.convert_numbers_to_strings, a)
    lu.assert_nil(M.convert_numbers_to_strings())

    local tests = {
        [true] = true, [1] = '1', [1.1] = '1', ['a'] = 'a', [{}] = {},
        [{nil, true, 1, 1.12, 'a', {}}] = {nil, true, '1', '1', 'a', {}},
        [{a = nil, b = true, c = 1, d = 1.12, e = 'a', f = {}}] =
            {a = nil, b = true, c = '1', d = '1', e = 'a', f = {}},
        [{a = nil, b = true, c = 1, d = 1.12, e = 'a',
            f = {nil, true, 1, 1.12, 'a', {}}}] = 
                {a = nil, b = true, c = '1', d = '1', e = 'a', 
                    f = {nil, true, '1', '1', 'a', {}}}
    }
    
    for k, v in pairs(tests) do
        lu.assert_equals(M.convert_numbers_to_strings(k), v)
    end
end

function test_core:test_read_json_file ()
    local invalid_inputs = {nil, false, '', {}}
    for _, invalid in ipairs(invalid_inputs) do
        lu.assert_error(M.read_json_file, invalid)
    end

    local ok, err, errno = M.read_json_file('<does not exist>')
    lu.assert_nil(ok)
    lu.assert_not_equals(err, '')
    lu.assert_equals(errno, 2)
    
    local fname = concat({DATA_DIR, 'test-read_json_file.json'}, PATH_SEP)
    local data, err, errno = M.read_json_file(fname)
    lu.assert_not_nil(data)
    lu.assert_nil(err)
    lu.assert_nil(errno)
    lu.assert_equals(data, NORM_SOURCE)
end


function test_core:test_write_json_file ()
    local invalid_inputs = {nil, false, '', {}}
    for _, invalid in ipairs(invalid_inputs) do
        lu.assert_error(M.read_json_file, nil, invalid)
    end

    local ok, err, errno = M.read_json_file('<does not exist>')
    lu.assert_nil(ok)
    lu.assert_not_equals(err, '')
    lu.assert_equals(errno, 2)
    
    local fname = concat({TMP_DIR, 'test-write_json_file.json'}, PATH_SEP)
    local ok, err, errno = os.remove(fname)
    if not ok and errno ~= 2 then error(err) end    
    local ok, err, errno = M.write_json_file(NORM_SOURCE, fname)
    lu.assert_true(ok)
    lu.assert_nil(err)
    lu.assert_nil(errno)

    local data, err,errno = M.read_json_file(fname)
    lu.assert_not_nil(data)
    lu.assert_nil(err)
    lu.assert_nil(errno)
    
    lu.assert_equals(data, NORM_SOURCE) 
end


test_retrieval = {}

function test_retrieval:setup ()
    if CONFIG['query-base-url'] then
        self.original_url = M.ZOTXT_QUERY_BASE_URL
        if CONFIG['query-base-url']:match('/$') then
            M.ZOTXT_QUERY_BASE_URL = CONFIG['query-base-url']
        else
            M.ZOTXT_QUERY_BASE_URL = CONFIG['query-base-url'] .. '/'
        end
    end
end

function test_retrieval:teardown ()
    if CONFIG['query-base-url'] then
        M.ZOTXT_QUERY_BASE_URL = self.original_url
    end
end

function test_retrieval:test_get_source ()
    local invalid_input = {nil, false, 0, '', {}}
    for _, invalid in pairs(invalid_input) do
        lu.assert_error(M.get_source, invalid)
    end

    lu.assert_nil(select(2, pcall(M.get_source, '<does not exist>')))

    local better_bibtex = copy(NORM_SOURCE)
    better_bibtex.id = 'haslanger2012ResistingRealitySocial'
    local zotero_id = copy(NORM_SOURCE)
    zotero_id.id = 'TPN8FXZV'
    
    local tests = {
        [NORM_SOURCE.id]    = NORM_SOURCE,
        [better_bibtex.id]  = better_bibtex,
        [zotero_id.id]      = zotero_id
    }
    
    for k, v in pairs(tests) do
        lu.assert_equals(M.get_source(k), v)
    end
end

function test_retrieval:test_update_bibliography ()
    local invalid_fnames = {nil, false, '', {}}
    local invalid_keys = {nil, false, 0, '', base}
    for _, fname in ipairs(invalid_fnames) do
        for _, keys in ipairs(invalid_keys) do
            lu.assert_error(M.update_bibliography, fname, keys)
        end
    end

    local fname = concat({TMP_DIR, 'test-update_bibliography.json'}, PATH_SEP)
    local ok, err, errno = os.remove(fname)
    if not ok and errno ~= 2 then error(err) end
    local ok, err = M.update_bibliography(fname, {'haslanger:2012resisting'})
    lu.assert_true(ok)
    lu.assert_nil(err)
    local data, err = M.read_json_file(fname)
    lu.assert_not_nil(data)
    lu.assert_nil(err)
    lu.assert_equals(data, {NORM_SOURCE})

    local ok, err = M.update_bibliography(fname, 
        {'haslanger:2012resisting', 'dotson:2016word'})
    lu.assert_true(ok)
    lu.assert_nil(err)
    local data, err = M.read_json_file(fname)
    lu.assert_not_nil(data)
    lu.assert_nil(err)
    lu.assert_equals(#data, 2)

    local ok, err = M.update_bibliography(fname, 
        {'haslanger:2012resisting', 'dotson:2016word'})
    lu.assert_true(ok)
    lu.assert_nil(err)
    local new, err = M.read_json_file(fname)
    lu.assert_not_nil(new)
    lu.assert_nil(err)
    lu.assert_equals(new, data)
end


-- # BOILERPLATE

--- Runs the tests
--
-- Looks up the `tests` metadata field in the current Pandoc document
-- and passes it to `lu.LuaUnit.run`, as is.
--
-- @tparam pandoc.Doc doc A Pandoc document.
function run (doc)
    local meta = doc.meta
    local tests
    if meta.tests then tests = stringify(meta.tests) end
    for k, v in pairs(meta) do CONFIG[k] = v end
    exit(lu.LuaUnit.run(tests))
end

-- 'Pandoc', rather than 'Meta', because there's always a Pandoc document.
return {{Pandoc = run}}


