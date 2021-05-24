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

#### Manual Shifting

Use the `shift-heading-level-by` attribute to control header
shifting.

#### Automatic Shifting

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

### Different Formats

Files are assumed to be written in Markdown, but sometimes one
will want to include files written in a different format. An
alternative format can be specified via the `format` attribute.
Only plain-text formats are accepted. The default format for all includes
can be set by the meta data variable `include-format`, which is useful
if you want all your files to be parsed in the same way as your main document,
e.g. with extensions.

### Filter by Formats

Files can be included and excluded on different formats by
using attribute `include-if-format=formatA;formatB;...`
and `exclude-if-format=formatA;formatB;...`, e.g.

````md
```{.include include-if-format=native;html;latex}
subdir/file-h.md
```

```{.include exclude-if-format=native;commonmark}
subdir/file-i.md
```
````

### Variable Substitution in Paths

If attribute `var-replace` is used, the patterns `${meta:<meta-var>}` or `${env:<env-var>}`
will be replaced by the corresponding meta data variable `<meta-var>` in the document or the
environment variable `<env-var>`, e.g.

````md
```{.include .var-replace}
${meta:subdir-name}/file-h.md
${env:SUBDIR_NAME}/file-h.md
```
````

### Raw Includes

You can also include the files in a raw block by using `raw=true`, e.g.

````md
```{.include raw=true format=latex include-if-format=latex}
subdir/file-h-latex.md
```
````

### Recursive Transclusion

Included files can in turn include other files. Note that all
filenames must be relative to the directory from which they are
included.
I.e., if a file `a/b.md` is included in the main
document, and another file `a/b/c.md` should be included from
`a/b.md`, then the relative path from `a/b.md` must be used, in
this case `b/c.md`. The full relative path will be automatically
generated in the final document. The same goes for image paths and
codeblock file paths using the `include-code-files` filter.

If you set the meta variable `include-paths-relative-to-cwd` to `true`,
all include paths are treated relative to pandoc's working directory.
You can selectively set the attribute `relative-to-current` on all pandoc
elements modiefied by this filter (e.g. image, codeblock file paths,
codeblock transclusion) which will treat the
paths relative to the directory from which they are included.

### Missing Includes

You can set the meta data variable `include-fail-if-read-error` to `true`
such that any not found include or read failure will fail
the convertion immediateley and error out.
Otherwise the missing includes are skipped by default.

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
