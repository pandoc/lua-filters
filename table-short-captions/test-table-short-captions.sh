#!/bin/sh

latex_result="$(cat -)"

assert_contains ()
{
    printf '%s' "$latex_result" | grep -qF "$1" -
    if [ $? -ne 0 ]; then
        printf 'Output does not contain `%s`.\n' "$1" >&2
        exit 1
    fi
}

# This tests the basic function of the filter alone.
# The output that we test for (in some cases) is still non-sensical,
#   as the filter puts the raw label into the caption for `pandoc-crossref`
#   to parse, yet this test does not filter through test pandoc-crossref.

# Preamble injection
assert_contains <<EOF
% -- begin:latex-table-short-captions --
EOF
assert_contains <<EOF
% -- end:latex-table-short-captions --
EOF

# Test 1
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl1, which does
not have a label.}\tabularnewline
EOF

# Test 2
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl2, in standard
\texttt{pandoc-crossref} form. \{\#tbl:tbl-label2\}}\tabularnewline
EOF

# Test 3
assert_contains <<EOF
\def\pandoctableshortcapt{}  % .unlisted
EOF
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl3, which is
\textbf{unlisted}. \{\#tbl:tbl-label3\}}\tabularnewline
EOF
assert_contains <<EOF
\undef\pandoctableshortcapt
EOF

# Test 4
assert_contains <<EOF
\def\pandoctableshortcapt{Table 4 \emph{short} capt.}
EOF
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl4, which has
an \textbf{overriding} short-caption. This is the expected usage.
\{\#tbl:tbl-label4\}}\tabularnewline
EOF
assert_contains <<EOF
\undef\pandoctableshortcapt
EOF

# Test 5
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl5, which does
not have a label, but does have empty braces at the end.
\{\}}\tabularnewline
EOF

# Test 6
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl6, which does
not have a label, but does have an empty span at the end.
}\tabularnewline
EOF

# Test 7
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl7, which is
improperly formatted, and will appear in the list of tables. This filter
requires that \texttt{.unlisted} is placed in a span. \{\#tbl:tbl-label7
.unlisted\}}\tabularnewline
EOF

# Test 8
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl8, which has
an empty short-caption. An empty short-caption does nothing. The long
caption will still be used. \{\#tbl:tbl-label8\}}\tabularnewline
EOF

# Test 9
assert_contains <<EOF
\def\pandoctableshortcapt{}  % .unlisted
EOF
assert_contains <<EOF
\caption{This is the \emph{italicised long caption} of tbl9, which is
\textbf{unlisted}, yet has a short-caption.
\{\#tbl:tbl-label9\}}\tabularnewline
EOF
assert_contains <<EOF
\undef\pandoctableshortcapt
EOF
