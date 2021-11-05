#! /bin/bash
echo Runing tests against insert-meta LUA filter
pandoc sample-document.md --lua-filter=include-meta.lua -o output.md --standalone
DIFF=$(diff -u expected.md output.md) 
if [ "$DIFF" != "" ] 
then
    echo "ERROR: Test for insert-meta LUA FAILED."
    echo "See DIFF below:"
    echo "$DIFF"
else
    echo "OK: Test for insert-meta LUA PASSED."
fi

