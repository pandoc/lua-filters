---
title: "Tests for table-short-captions.lua"
lot: true
---

These tests are written so that if **bold font** appears in the LOT, something is wrong.


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl1, which does not have a label.


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl2, which does not have a label, but does have empty braces at the end.  {}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl3.  {#tbl:tbl-label3}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl4, which is **unlisted**. This is expected usage.  {#tbl:tbl-label4 .unlisted}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl5, which has an **overriding** short-caption. This is the expected usage. {#tbl:tbl-label5 short-caption="Table 5 *short* capt."}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl6, which is **unlisted**, yet has a short-caption.  {#tbl:tbl-label6 .unlisted short-caption="Table 6 **unlisted** *short* capt."}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl7, which is **unlisted**, yet has a short-caption and other bogus classes {#tbl:tbl-label7 .unused-class .unlisted short-caption="Table 7 **unlisted** *short* capt." .more-classes}


| cola | colb |
| ---- | ---- |
| a1   | b1   |
| a2   | b2   |

Table: This is the *italicised long caption* of tbl8, which has an empty short-caption. An empty short-caption does nothing. The long caption will still be used. {#tbl:tbl-label8 short-caption=""}


This is the last paragraph, just to tie things up.
