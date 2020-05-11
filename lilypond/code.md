The filter should leave code elements (like this: `putStrLn "hello, world!"`)
and code blocks (like this:

```lua
function foo()
  return "foo"
end
```

) alone if they aren't tagged with the `lilypond` class.

It should also ignore elements that have the `ly-norender` class: `relative
c'`{.lilypond .ly-norender}.
