package = "LuaUnit"
version = "3.3-1"
source =
{
	url = 'https://github.com/bluebird75/luaunit/releases/download/LUAUNIT_V3_3/rock-luaunit-3.3.zip'
}

description =
{
	summary = "A unit testing framework for Lua",
	detailed =
	[[
		LuaUnit is a popular unit-testing framework for Lua, with an interface typical
		of xUnit libraries (Python unittest, Junit, NUnit, ...). It supports 
		several output formats (Text, TAP, JUnit, ...) to be used directly or work with Continuous Integration platforms
		(Jenkins, Hudson, ...).

		For simplicity, LuaUnit is contained into a single-file and has no external dependency. 

		Tutorial and reference documentation is available on
		[read-the-docs](http://luaunit.readthedocs.org/en/latest/)

		LuaUnit may also be used as an assertion library, to validate assertions inside a running program. In addition, it provides
		a pretty stringifier which converts any type into a nicely formatted string (including complex nested or recursive tables).

		To install LuaUnit from LuaRocks, you need at least LuaRocks version 2.4.4 (due to old versions of wget being incompatible
		with GitHub https downloading)

	]],
	homepage = "http://github.com/bluebird75/luaunit",
	license = "BSD",
	maintainer = 'Philippe Fremy <phil at freehackers dot org>',
}

dependencies =
{
	"lua >= 5.1", "lua < 5.4"
}

build =
{
	type = "builtin",
	modules =
	{
		luaunit = "luaunit.lua"
	},
	copy_directories = { "doc", "test" }
}
