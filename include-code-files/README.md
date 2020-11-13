# include-code-files

Filter to include code from source files.

The filter is largely inspired by
[pandoc-include-code](https://github.com/owickstrom/pandoc-include-code).

## Usage

The filter recognizes code blocks with the `include` attribute present. It
swaps the content of the code block with contents from a file.

### Including Files

The simplest way to use this filter is to include an entire file:

    ```{include="hello.c"}
    ```

You can still use other attributes, and classes, to control the code blocks:

    ```{.c include="hello.c" numberLines}
    ```

### Ranges

If you want to include a specific range of lines, use `startLine` and `endLine`:

    ```{include="hello.c" startLine=35 endLine=80}
    ```

`start-line` and `end-line` alternatives are also recognized.

### Dedent

Using the `dedent` attribute, you can have whitespaces removed on each line,
where possible (non-whitespace character will not be removed even if they occur
in the dedent area).

    ```{include="hello.c" dedent=4}
    ```

### Line Numbers

If you include the `numberLines` class in your code block, and use `include`,
the `startFrom` attribute will be added with respect to the included code's
location in the source file.

    ```{include="hello.c" startLine=35 endLine=80 .numberLines}
    ```

## Example

An HTML can be produced with this command:

    pandoc --lua-filter=include-code-files.lua sample.md --output result.html

