# include-files

Filter to include other files in the document.

## Usage

Use a special code block with class `include` to include files of
the same format as the input. Each code line is treated as the
filename of a file, parsed, and the result is added to the
document.

Metadata from included files is discarded.

### Shifting Headings

The default is to include the subdocuments unchanged, but it can
be convenient to modify the level of headers; a top-level header
in an included file should be a second or third-level header in
the final document.

#### Manual shifting

Use the `shift-heading-level-by` attribute to control header
shifting.

#### Automatic shifting

1. Add metadata `-M include-auto` to enable automatic shifting.
2. Do not specify `shift-heading-level-by`
3. It will be inferred to the last heading level encountered

_Example_ :

````md
# Title f

This is `file-f.md`.

## Subtitle f

```{.include} >> equivalent to {.include shift-heading-level-by=2}
file-a.md
```

```{.include shift-heading-level-by=1} >> force shift to be 1
file-a.md
```
````

### Comments

Comment lines can be added in the include block by beginning a
line with two `//` characters.

### Different formats

Files are assumed to be written in Markdown, but sometimes one
will want to include files written in a different format. An
alternative format can be specified via the `format` attribute.
Only plain-text formats are accepted.

### Recursive transclusion

Included files can in turn include other files. Note that all
filenames must be relative to the directory from which pandoc is
run. I.e., if a file `a/b.md` is included in the main document,
and another file `a/b/c.md` should be included, the full relative
path must be used. Writing `b/c.md` in `a/b.md` would _not_ work.

## Example

Let's assume we are writing a longer document, like a thesis.
Each chapter and appendix section resides in its own file, with
some additional information in the main file `main.md`:

    ---
    author: me
    title: Thesis
    ---

    # Frontmatter

    Thanks everyone!

    <!-- actual chapters start here -->

    ``` {.include}
    chapters/introduction.md
    chapters/methods.md
    chapters/results.md
    chapters/discussion.md
    ```

    # Appendix

    More info goes here.

    ``` {.include shift-heading-level-by=1}
    // headings in included documents are shifted down a level,
    // a level 1 heading becomes level 2.
    appendix/questionaire.md
    ```

An HTML can be produced with this command:

    pandoc --lua-filter=include-files.lua main.md --output result.html
