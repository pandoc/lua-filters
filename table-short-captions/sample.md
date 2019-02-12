---
title: "Tests for table-short-captions.lua"
lot: true
---

These tests are written so that if **bold font** appears in the LOT, something is wrong.

The tests are split into two: expected uses, and non-standard uses/errors.  
The non-standard uses are presented in this document for troubleshooting purposes, and to ensure the filter doesn't crash in corner cases.

# Standard usage

| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl1, which does not have a label.


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl2, in standard `pandoc-crossref` form.  {#tbl:tbl-label2}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl3, which is **unlisted**.  []{#tbl:tbl-label3 .unlisted}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl4, which has an **overriding** short-caption. This is the expected usage.  []{#tbl:tbl-label4 short-caption="Table 4 *short* capt."}


# Non-standard usage/errors

| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl5, which does not have a label, but does have empty braces at the end.  {}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl6, which does not have a label, but does have an empty span at the end.  []{}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl7, which is improperly formatted, and will appear in the list of tables. This filter requires that `.unlisted` is placed in a span.  {#tbl:tbl-label7 .unlisted}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl8, which has an empty short-caption. An empty short-caption does nothing. The long caption will still be used.  []{#tbl:tbl-label8 short-caption=""}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl9, which is **unlisted**, yet has a short-caption.  []{#tbl:tbl-label9 .unlisted short-caption="Table 9 **unlisted** *short* capt."}
