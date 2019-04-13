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

# whether we are using the scrlttr2 class
assert_contains '{scrlttr2}'

assert_contains '\setkomavar{fromname}{Jane Doe}'
assert_contains '\setkomavar{fromaddress}{35 Industry Way\\ Springfield}'
assert_contains '\setkomavar{subject}{Letter of Reference}'
assert_contains '\setkomavar{date}{February 29, 2020}'

# Custom opening and default closing
assert_contains '\opening{To Whom It May Concern,}'
assert_contains '\closing{Sincerely,}'

# Author and date
assert_contains '\author{Jane Doe}'
assert_contains '\date{February 29, 2020}'

# Recipient address
assert_contains '\begin{letter}{Fireworks Inc.\\ 123 Fake St\\ 58008 Springfield}'
