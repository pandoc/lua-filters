--- main.lua - Main unit tests for pandoc-zotxt.lua. 
--
-- @script main.lua
-- @author Odin Kroeger
-- @copyright 2018, 2019 Odin Kroeger
-- @license MIT
--
-- This script must be run as a Pandoc filter from the root of the repository.
--
--
-- LICENSE
-- =======
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

-- SHORTHANDS
-- ==========

local concat = table.concat
local unpack = table.unpack
local format = string.format


-- LIBRARIES
-- =========

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

local SCRIPT_DIR, SCRIPT_NAME = split_path(PANDOC_SCRIPT_FILE)
local TEST_BASE_DIR = SCRIPT_DIR .. PATH_SEP .. '..'
local REPO_BASE_DIR = TEST_BASE_DIR .. PATH_SEP .. '..'

package.path = package.path .. ';' .. 
    concat({REPO_BASE_DIR, 'share', 'lua', '5.3', '?.lua'}, PATH_SEP)

local P = require 'pandoc-zotxt'


-- FUNCTIONS
-- =========

--- Prints warnings to STDERR.
--
-- @tparam string ... Strings to be written to STDERR.
--
-- Prefixes every line with `NAME` and ": " and
-- appends a single linefeed if needed.
function warn (...)
    local stderr = io.stderr
    local str = concat({...})
    for line in str:gmatch('([^\n]*)\n?') do
        stderr:write('main.lua: ', line, '\n')
    end
end


--- Tests if two lists are equal.
--
-- @tparam tbl a First list.
-- @tparam tbl b Second list.
--
-- @treturn bool Whether they are equal.
function list_equals (a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if type(a[i]) == 'table' and type(b[i]) == 'table' then
            return list_equals(a[i], b[i])
        elseif a[i] ~= b[i] then
            return false
        end
    end
    return true
end


--- Tests if two tables are equal.
--
-- @tparam tbl a First table.
-- @tparam tbl b Second table.
--
-- @treturn bool Whether they are equal.
function tbl_equals (a, b)
    local keys = {}
    for k, _ in pairs(a) do keys[k] = true end
    for k, _ in pairs(b) do keys[k] = true end
    for k, _ in pairs(keys) do
        if type(a[k]) == 'table' and type(b[k]) == 'table' then
            return tbl_equals(a[k], b[k])
        elseif a[k] ~= b[k] then
            return false
        end
    end
    return true
end


-- DATA
-- ====

local SAMPLE_SOURCE = {
    id = 'haslanger:2012resisting', type = 'book',
    author = {{family = 'Haslanger', given = 'Sally'}},
    title = 'Resisting Reality: Social Construction and Social Critique',
    publisher = 'Oxford University Press',
    ['publisher-place'] = 'Oxford',
    issued = {['date-parts'] = {{'2012'}}},
    ['title-short'] = 'Resisting Reality',
    ISBN = '978-0-19-989262-4'
}


-- TESTS
-- =====

-- split_path
-- ----------

do
    for _, v in pairs({nil, false, 0, {}, function () end}) do
        local ok = pcall(P.split_path, v)
        assert(ok == false)
    end

    local ok, err = pcall(P.split_path, '')
    assert(ok == false)
    assert(err:match('path is the empty string'))

    local dir, fname = P.split_path('.')
    assert(dir == '.')
    assert(fname == '.')
    
    local dir, fname = P.split_path('..')
    assert(dir == '.')
    assert(fname == '..')

    local dir, fname = P.split_path('/')
    assert(dir == '/')
    assert(fname == '.')

    local dir, fname = P.split_path('//')
    assert(dir == '/')
    assert(fname == '.')

    local dir, fname = P.split_path('///////')
    assert(dir == '/')
    assert(fname == '.')

    local dir, fname = P.split_path('/.//////')
    assert(dir == '/')
    assert(fname == '.')

    local dir, fname = P.split_path('/.////.//')
    assert(dir == '/')
    assert(fname == '.')

    local dir, fname = P.split_path('/.//..//.//')
    assert(dir == '/..')
    assert(fname == '.')

    local dir, fname = P.split_path('/.//..//.//../')
    assert(dir == '/../..')
    assert(fname == '.')

    local dir, fname = P.split_path('a')
    assert(dir == '.')
    assert(fname == 'a')
    
    local dir, fname = P.split_path('./a')
    assert(dir == '.')
    assert(fname == 'a')
    
    local dir, fname = P.split_path('../a')
    assert(dir == '..')
    assert(fname == 'a')

    local dir, fname = P.split_path('/a')
    assert(dir == '/')
    assert(fname == 'a')

    local dir, fname = P.split_path('//a')
    assert(dir == '/')
    assert(fname == 'a')

    local dir, fname = P.split_path('///////a')
    assert(dir == '/')
    assert(fname == 'a')

    local dir, fname = P.split_path('/.//////a')
    assert(dir == '/')
    assert(fname == 'a')

    local dir, fname = P.split_path('/.////.//a')
    assert(dir == '/')
    assert(fname == 'a')

    local dir, fname = P.split_path('/.//..//.//a')
    assert(dir == '/..')
    assert(fname == 'a')

    local dir, fname = P.split_path('/.//..//.//../a')
    assert(dir == '/../..')
    assert(fname == 'a')
    
    local dir, fname = P.split_path('a/b')
    assert(dir == 'a')
    assert(fname == 'b')
    
    local dir, fname = P.split_path('./a/b')
    assert(dir == 'a')
    assert(fname == 'b')
    
    local dir, fname = P.split_path('../a/b')
    assert(dir == '../a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/a/b')
    assert(dir == '/a')
    assert(fname == 'b')

    local dir, fname = P.split_path('//a/b')
    assert(dir == '/a')
    assert(fname == 'b')

    local dir, fname = P.split_path('///////a/b')
    assert(dir == '/a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/.//////a/b')
    assert(dir == '/a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/.////.//a/b')
    assert(dir == '/a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/.//..//.//a/b')
    assert(dir == '/../a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/.//..//.//../a/b')
    assert(dir == '/../../a')
    assert(fname == 'b')

    local dir, fname = P.split_path('/a/b/c/d')
    assert(dir == '/a/b/c')
    assert(fname == 'd')

    local dir, fname = P.split_path('a/b/c/d')
    assert(dir == 'a/b/c')
    assert(fname == 'd')

    local dir, fname = P.split_path('/a/b/c/d')
    assert(dir == '/a/b/c')
    assert(fname == 'd')

    local dir, fname = P.split_path('a/../.././c/d')
    assert(dir == 'a/../../c')
    assert(fname == 'd')
end


-- map
-- ---

do
    local base = function (x) return x end
    local succ = function (x) return x + 1 end
    
    for _, a in pairs({nil, false, 0, '', {}}) do
        for _, b in pairs({nil, false, 0, '', base}) do
            assert(pcall(P.map, a, b) == false)
        end
    end
    
    assert(list_equals(P.map(base, {}), {}))
    assert(list_equals(P.map(base, {0}), {0}))
    assert(list_equals(P.map(base, {0, 1, 2}), {0, 1, 2}))
    assert(list_equals(P.map(succ, {}), {}))
    assert(list_equals(P.map(succ, {0}), {1}))
    assert(list_equals(P.map(succ, {0, 1, 2}), {1, 2, 3}))
end


-- get_position
-- ------------

do
    for _, v in pairs({nil, false, 0, 'x', function () end}) do
        assert(pcall(P.get_position, nil, v) == false)
    end

    assert(P.get_position(nil, {}) == nil)
    assert(P.get_position(nil, {1, 2, 3}) == nil)
    assert(P.get_position(2, {1}) == nil)
    assert(P.get_position(1, {1}) == 1)
    assert(P.get_position(1, {1, 2, 3}) == 1)
    assert(P.get_position(2, {1, 2, 3}) == 2)
    assert(P.get_position(3, {1, 2, 3}) == 3)
end


-- get_input_directory
-- -------------------

do
    assert(P.get_input_directory() == PATH_SEP .. 'dev')
end


-- convert_numbers_to_strings
-- --------------------------

do
    local a = {}
    local b = {}
    a.b = b
    b.a = a
    local ok = pcall(P.convert_numbers_to_strings, a)
    assert(ok == false)
    
    assert(P.convert_numbers_to_strings(nil) == nil)
    assert(P.convert_numbers_to_strings(true) == true)
    assert(P.convert_numbers_to_strings(1) == '1')
    assert(P.convert_numbers_to_strings(1.12) == '1')
    assert(P.convert_numbers_to_strings('a') == 'a')
    assert(list_equals(P.convert_numbers_to_strings({}), {}))
    assert(list_equals({nil, true, '1', '1', 'a', {}},
        P.convert_numbers_to_strings({nil, true, 1, 1.12, 'a', {}})))
    assert(list_equals({a = nil, b = true, c = '1', d = '1', e = 'a', f = {}},
        P.convert_numbers_to_strings({a = nil, b = true, c = 1, d = 1.12,
            e = 'a', f = {}})))
    assert(list_equals({a = nil, b = true, c = '1', d = '1', e = 'a', 
        f = {nil, true, '1', '1', 'a', {}}},
        P.convert_numbers_to_strings({a = nil, b = true, c = 1, d = 1.12,
            e = 'a', f = {nil, true, 1, 1.12, 'a', {}}})))
end


-- get_source
-- ----------

do
    assert(pcall(P.get_source) == false)
    for _, invalid in pairs({nil, false, 0, '', {}}) do
        assert(pcall(P.get_source, invalid) == false)
    end
    assert(P.get_source('<highly unlikely citekey>') == nil)
    assert(tbl_equals(P.get_source('haslanger:2012resisting'), SAMPLE_SOURCE))
end


-- read_json_file
-- --------------

do
    for _, invalid in pairs({nil, false, '', {}}) do
        assert(pcall(P.read_json_file, invalid) == false)
    end

    local data, err, errno = P.read_json_file('<non-existant>')
    assert(data == nil)
    assert(err ~= '')
    assert(errno == 2)

    local fname = concat({TEST_BASE_DIR, 
        'data', 'test-read_json_file.json'}, PATH_SEP)
    local data, err, errno = P.read_json_file(fname)
    assert(data ~= nil)
    assert(err == nil)
    assert(errno == nil)
    assert(tbl_equals(data, SAMPLE_SOURCE))
end


-- write_json_file
-- ---------------

do
    for _, invalid in pairs({nil, false, '', {}}) do
        assert(pcall(P.write_json_file, nil, invalid) == false)
    end

    local fname = concat({TEST_BASE_DIR, 
        'tmp', 'test-write_json_file.json'}, PATH_SEP)
    local ok, err, errno = os.remove(fname)
    if not ok and errno ~= 2 then error(err) end
    local ok, err, errno = P.write_json_file(SAMPLE_SOURCE, fname)
    assert(ok == true)
    assert(err == nil)
    assert(errno == nil)
    
    local norm = P.read_json_file(fname)
    assert(tbl_equals(SAMPLE_SOURCE, norm))
end


-- update_bibliography
-- -------------------

do
    
    for _, fname in pairs({nil, false, '', {}}) do
        for _, keys in pairs({nil, false, 0, '', base}) do
            assert(pcall(P.update_bibliography, fname, keys) == false)
        end
    end

    local fname = concat({TEST_BASE_DIR, 'tmp',
        'test-update_bibliography.json'}, PATH_SEP)
    local ok, err, errno = os.remove(fname)
    if not ok and errno ~= 2 then error(err) end
    local ok, err = P.update_bibliography(fname, {'haslanger:2012resisting'})
    assert(ok == true)
    assert(err == nil)
    local data, err = P.read_json_file(fname)
    assert(data ~= nil)
    assert(err == nil)
    assert(tbl_equals(data, {SAMPLE_SOURCE}))

    local ok, err = P.update_bibliography(fname, 
        {'haslanger:2012resisting', 'dotson:2016word'})
    assert(ok == true)
    assert(err == nil)
    local data, err = P.read_json_file(fname)
    assert(data ~= nil)
    assert(err == nil)
    assert(#data == 2)

    local ok, err = P.update_bibliography(fname, 
        {'haslanger:2012resisting', 'dotson:2016word'})
    assert(ok == true)
    assert(err == nil)
    local new, err = P.read_json_file(fname)
    assert(new ~= nil)
    assert(err == nil)
    assert(tbl_equals(data, new))
end