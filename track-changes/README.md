# Tracks changes in LaTeX and HTML or removes them in other output formats

The Pandoc Docx reader and writer supports track changes of MS Word
(command line parameter `--track-changes=accept|reject|all`).

If `--track-changes=all` was used to read a docx file, track changes
and/or comments are included in the AST as spans and are written to any
other output formats than docx and clutters the output.

This Lua filter addresses this problem by interpreting the parameter
`--track-changes` (pandoc version >= 2.1.1) or the metadata variable
`trackChanges: accept|reject|all` (set either in a YAML block or with
`-M`) and accepts/rejects changes and removes comments for all output
formats including docx. In case of `--track-changes=all` and for html
and latex, it converts track changings and comments to appropriate
commands (for LaTex provided by the [changes
package](https://ctan.org/pkg/changes)) and tries to mimic the
visualization as in MS Word.
