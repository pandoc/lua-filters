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

# whether we are using the change package
assert_contains <<EOF
\usepackage{changes}
EOF

# Author colors
assert_contains '\definechangesauthor[name={JFK}, color=auth2]{JFK}'

# Additions, notes, and deletions
assert_contains <<EOF
Here is a \note[id=JFK]{Why?}\hlnote{com\added[id=SWS]{m}ent with nest\deleted[id=FKA]{t}ed changes}.
EOF
