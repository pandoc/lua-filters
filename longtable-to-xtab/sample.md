---
classoption:
  - twocolumn
  - landscape
---

This is a two column layout with tables. Without the `longtable-to-xtab`
filter trying to convert this document to PDF fails because Pandoc's
favoured table package, `longtable`, isn't compatible with multiple
column layouts.

# Table with headers and caption

-------------------------------------------------------------
 Centered   Default           Right Left
  Header    Aligned         Aligned Aligned[^1]
----------- ------- --------------- -------------------------
   First    row                12.0 Example of a row that
                                    spans multiple lines.

  Second    row                 5.0 Here's another one. Note
                                    the blank line between
                                    rows.
-------------------------------------------------------------

Table: Here's the *caption*. It, too, may span
  multiple lines.

[^1]: Footnote in a table.

# Table without headers

----------- ------- --------------- -------------------------
   First    row                12.0 Example of a row that
                                    spans multiple lines.

  Second    row                 5.0 Here's another one. Note
                                    the blank line between
                                    rows.
----------- ------ ---------------- ----------------------------

Table: this table doesn't have headers.

# Table without caption

-------------------------------------------------------------
 Centered   Default           Right Left
  Header    Aligned         Aligned Aligned
----------- ------- --------------- -------------------------
   First    row                12.0 Example of a row that
                                    spans multiple lines.

  Second    row                 5.0 Here's another one. Note
                                    the blank line between
                                    rows.
-------------------------------------------------------------
