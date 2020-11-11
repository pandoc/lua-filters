# codeblock-var-replace

Filter to replace variables in code blocks with values from environment
or meta data. All variables in the form `${namespace:name}` in a code
block with a class `.var-replace` are replaced.
This is very useful in conjuction with a downstream filter `include-files.lua` filter.

## Variables

A variables needs to be of the form `${namespace:name}` where
`namespace` is currently one of `env`,`meta` with the following replacement behavior:

- `env` : Substituting the environment variable `name`.
- `meta` : Substituting the **stringified** variable `name` from the meta data block.

## Example

Note that meta data is parsed as markdown, therefore use a
general code blocks `` `text` ``:

    ---
    author: "`The fearful bear`"
    title: Thesis

    monkey: "`Hello:  I am a monkey`"
    "giraffe and zebra" : "`cool and humble  !`"
    mypath: "`chapters:   1/A B.txt`"
    food: "chocolate"
    ---

    ## Replace

    ``` {.var-replace}
    ${meta:monkey} and ${env:BANANA}

    Zebras and giraffes are ${meta:giraffe and zebra}

    ${meta:author} thanks for everything in '${meta:mypath}'
    and of course eat some ${meta:food}
    ```

