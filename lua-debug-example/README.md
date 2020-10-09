# Debugging Lua filters

You can debug Pandoc Lua filters using [Zerobrane
Studio](https://studio.zerobrane.com). This GUI debugger requires
`luasocket` and `mobdebug`, both are bundled in Zerobrane, or you
can use your Lua installed versions.

## Without Lua Installed:
If you don't have Lua installed on your system, you must update
the environment search path to use `mobdebug.lua` and `luasocket`
from Zerobrane's install location. See
[documentation](https://studio.zerobrane.com/doc-remote-debugging)
for details. For example, on macOS this would be:

```bash
export ZBS=/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio
export LUA_PATH="./?.lua;$ZBS/lualibs/?/?.lua;$ZBS/lualibs/?.lua"
export LUA_CPATH="$ZBS/bin/?.dylib;$ZBS/bin/clibs53/?.dylib;$ZBS/bin/clibs53/?/?.dylib"
```

## With Lua Installed:
If you have installed Lua v5.3 and added `mobdebug` + `luasocket`
using `luarocks` then they should be available in the default path
locations (at least for POSIX systems), and you shouldn't need to
set any path variables.

## How to Trigger the Debugger:
Ensure the `lua-debug-example.lua` file is opened in the Zerobrane
editor; Project > Start Debugger Server is turned ON; and
editor.autoactivate = true is enabled in your `user.lua` settings
file.

Then run `pandoc` from a terminal with the filter that is open in
the editor (here we use STDIN to give `pandoc` some input, press
<kbd>ctrl</kbd>+<kbd>d</kbd> to finish entering text):

```
> pandoc --lua-filter lua-debug-example.lua
Here is a *test* for **REPL** debugging.

```

Zerobrane's debugging interface will activate. Use the stack
window and remote console to examine the environment and execute
Lua commands while stepping through the code.

## Command-line Use:
With mobdebug and luasocket installed alongside Lua, you can also
debug directly from your terminal without running the IDE:

```bash
> lua -e "require('mobdebug').listen()"
```

But Zerobrane Studio offers much richer functionality…
