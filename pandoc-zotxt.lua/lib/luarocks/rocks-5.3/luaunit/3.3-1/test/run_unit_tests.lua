#!/usr/bin/env lua

if not pcall( require, 'test.test_luaunit') then
	-- run_unit_tests shall also work when called directly from the test directory
	require('test_luaunit')

	-- we must disable this test, not working in this case because it expects 
	-- the stack trace to start with test/test_luaunit.lua
	TestLuaUnitUtilities.test_FailFmt = nil
end
local lu = require('luaunit')

lu.LuaUnit.verbosity = 2
os.exit( lu.LuaUnit.run() )
