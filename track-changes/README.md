# Tracks changes in LaTeX or removes them in other output formats

Pandocs Docx reader and writer supports track changes of MS Word.
This can be enabled with the command line parameter `--track-changes=accept|reject|all`.

According to the documentation: "accept (the default), inserts all insertions, and ignores all deletions."
Unfortunately, this is not true for other writers than docx.
Instead, the spans introduced by the docx reader (if track changing was enabled), clutters the output.

Here, two Lua filters address this problem. The first filter `track-changes-final.lua` is a generic filter for all output formats which just accepts all changes and removes comments. The second filter `track-changes-latex.lua` translates track changings and comments to the appropriate LaTeX commands provided by the [changes package](https://ctan.org/pkg/changes).