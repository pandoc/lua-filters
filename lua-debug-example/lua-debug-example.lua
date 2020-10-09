--[[
# Lua Debug Example
This filter demonstrates how to add mobdebug commands to stop execution within
the filter functions, see README.md for details how to install and set up
Zerobrane Studio.
]]

md = require("mobdebug")
md.start()

function Emph(elem)
	md.pause() --breakpoint
	return elem.content
end

function Strong(elem)
	md.pause() --breakpoint
	return pandoc.SmallCaps(elem.content)
end