#!/usr/bin/env python

"""
Unit tests for the pandoc minted.lua filter.
"""

# Lint this file with: flake8 --max-line-length=80
import os
import subprocess
import sys
import textwrap

code_block = textwrap.dedent('''
    ## A Code Block

    ```{.cpp}
    auto mult = []<typename T, typename U>(T const & x, U const & y) {
        return x * y;
    };
    ```
''')
"""
The base CodeBlock code.  {.cpp} is used as a replacement marker in most tests!
"""

inline_code = textwrap.dedent('''
    ## Inline Code

    `#include <type_traits>`{.cpp}
''')
"""
The base Code code.  {.cpp} is used as a replacement marker in most tests!
"""


def run_pandoc(pandoc_args, stdin):
    """Run pandoc with the specified arguments, returning the output."""
    # The input / output should be small enough for these tests that buffer
    # overflows should not happen.
    pandoc_proc = subprocess.Popen(
        ["pandoc"] + pandoc_args,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE
    )

    # Python 3.x and later require communicating with bytes.
    if sys.version_info[0] >= 3:
        stdin = bytes(stdin, "utf-8")

    stdout, stderr = pandoc_proc.communicate(input=stdin)
    if pandoc_proc.returncode != 0:
        sys.stderr.write("Non-zero exit code of {ret} from pandoc!\n".format(
            ret=pandoc_proc.returncode
        ))
        sys.stderr.write("pandoc stderr: {stderr}".format(
            stderr=stderr.decode("utf-8")
        ))
        sys.exit(1)

    return stdout.decode("utf-8")


def fail_test(test_name, messages, ansi_color_code="31"):
    """
    Print failure message and ``sys.exit(1)``.

    ``test_name`` (str)
        The name of the test (to make finding in code easier).

    ``messages`` (list of str -- or -- str)
        A single string, or list of strings, to print out to ``stderr`` that
        explain the reason for the test failure.

    ``ansi_color_code`` (str)
        A an ANSI color code to use to colorize the failure message :)  Default
        is ``"31"``, which is red.
    """
    sys.stderr.write(
        "\033[0;{ansi_color_code}mTest {test_name} FAILED\033[0m\n".format(
            ansi_color_code=ansi_color_code, test_name=test_name
        )
    )
    if isinstance(messages, list):
        for m in messages:
            sys.stderr.write("--> {m}\n".format(m=m))
    else:
        sys.stderr.write("--> {messages}\n".format(messages=messages))
    sys.exit(1)


def ensure_fragile(test_name, pandoc_output):
    r"""
    Ensure that every \begin{frame} has (at least one) fragile.

    ``test_name`` (str)
        The name of the test (forwards to ``fail_test``).

    ``pandoc_output`` (str)
        The pandoc output for the test case.
    """
    for line in pandoc_output.splitlines():
        if r"\begin{frame}" in line:
            if "fragile" not in line:
                fail_test(
                    test_name,
                    r"\begin{frame} without 'fragile': {line}".format(line=line)
                )


def ensure_present(test_name, string, pandoc_output):
    """
    Assert that ``string`` is found in ``pandoc_output``.

    ``test_name`` (str)
        The name of the test (forwards to ``fail_test``).

    ``string`` (str)
        The string to check verbatim ``string in pandoc_output``.

    ``pandoc_output`` (str)
        The pandoc output for the test case.
    """
    if string not in pandoc_output:
        fail_test(
            test_name,
            "The requested string '{string}' was not found in:\n{pout}".format(
                string=string, pout=pandoc_output
            )
        )


def ensure_not_present(test_name, string, pandoc_output):
    """
    Assert that ``string`` is **not** found in ``pandoc_output``.

    ``test_name`` (str)
        The name of the test (forwards to ``fail_test``).

    ``string`` (str)
        The string to check verbatim ``string not in pandoc_output``.

    ``pandoc_output`` (str)
        The pandoc output for the test case.
    """
    if string in pandoc_output:
        fail_test(
            test_name,
            "The forbidden string '{string}' was found in:\n{pout}".format(
                string=string, pout=pandoc_output
            )
        )


def run_tex_tests(args, fmt):
    """
    Run same tests for latex writers.

    ``args`` (list of str)
        The base list of arguments to forward to pandoc.

    ``fmt`` (str)
        The format is assumed to be either 'latex' or 'beamer'.
    """
    def verify(test_name, md, string):
        """Run pandoc, ensure fragile, and string in output."""
        output = run_pandoc(args + ["-t", fmt], md)
        if fmt == "beamer":
            ensure_fragile(test_name, output)
        else:  # latex writer
            ensure_not_present(test_name, "fragile", output)
        ensure_present(test_name, string, output)
        # if `nil` is present, that likely means a problem parsing the metadata
        ensure_not_present(test_name, "nil", output)

    ############################################################################
    # CodeBlock tests.                                                         #
    ############################################################################
    begin_minted = r"\begin{{minted}}[{attrs}]{{{lang}}}"
    verify(
        "[code-block] default",
        code_block,
        begin_minted.format(attrs="autogobble", lang="cpp")
    )
    verify(
        "[code-block] no_default_autogobble",
        textwrap.dedent('''
            ---
            minted:
              no_default_autogobble: true
            ---
            {code_block}
        ''').format(code_block=code_block),
        begin_minted.format(attrs="", lang="cpp")
    )
    verify(
        "[code-block] default block language is 'text'",
        code_block.replace("{.cpp}", ""),
        begin_minted.format(attrs="autogobble", lang="text")
    )
    verify(
        "[code-block] user provided default_block_language",
        textwrap.dedent('''
            ---
            minted:
              default_block_language: "haskell"
            ---
            {code_block}
        ''').format(code_block=code_block.replace("{.cpp}", "")),
        begin_minted.format(attrs="autogobble", lang="haskell")
    )
    verify(
        "[code-block] user provided block_attributes",
        textwrap.dedent('''
            ---
            minted:
              block_attributes:
                - "showspaces"
                - "space=."
            ---
            {code_block}
        ''').format(code_block=code_block),
        begin_minted.format(
            attrs=",".join(["showspaces", "space=.", "autogobble"]),
            lang="cpp"
        )
    )
    verify(
        "[code-block] user provided block_attributes and no_default_autogobble",
        textwrap.dedent('''
            ---
            minted:
              no_default_autogobble: true
              block_attributes:
                - "style=monokai"
                - "bgcolor=monokai_bg"
            ---
            {code_block}
        ''').format(code_block=code_block),
        begin_minted.format(
            attrs=",".join(["style=monokai", "bgcolor=monokai_bg"]), lang="cpp"
        )
    )
    verify(
        "[code-block] attributes on code block",
        code_block.replace(
            "{.cpp}", "{.cpp .showspaces bgcolor=tango_bg style=tango}"
        ),
        begin_minted.format(
            attrs=",".join([
                "showspaces", "bgcolor=tango_bg", "style=tango", "autogobble"
            ]),
            lang="cpp"
        )
    )
    verify(
        "[code-block] attributes on code block + user block_attributes",
        textwrap.dedent('''
            ---
            minted:
              block_attributes:
                - "showspaces"
                - "space=."
            ---
            {code_block}
        ''').format(
            code_block=code_block.replace(
                "{.cpp}", "{.cpp bgcolor=tango_bg style=tango}"
            )
        ),
        begin_minted.format(
            attrs=",".join([
                "bgcolor=tango_bg",
                "style=tango",
                "showspaces",
                "space=.",
                "autogobble"
            ]),
            lang="cpp"
        )
    )
    verify(
        "[code-block] traditional fenced code block",
        code_block.replace("{.cpp}", "cpp"),
        begin_minted.format(attrs="autogobble", lang="cpp")
    )
    verify(
        "[code-block] non-minted attributes not forwarded",
        code_block.replace("{.cpp}", "{.cpp .showspaces .hello}"),
        begin_minted.format(
            attrs=",".join(["showspaces", "autogobble"]), lang="cpp"
        )
    )

    ############################################################################
    # Inline Code tests.                                                       #
    ############################################################################
    mintinline = r"\mintinline[{attrs}]{{{lang}}}"
    verify(
        "[inline-code] default",
        inline_code,
        mintinline.format(attrs="", lang="cpp")
    )
    verify(
        "[inline-code] default language is text",
        inline_code.replace("{.cpp}", ""),
        mintinline.format(attrs="", lang="text")
    )
    verify(
        "[inline-code] no_mintinline globally turned off",
        textwrap.dedent('''
            ---
            minted:
              no_mintinline: true
            ---
            {inline_code}
        ''').format(inline_code=inline_code),
        r"\texttt{#include <type_traits>}"
    )
    verify(
        "[inline-code] .no_minted class bypasses single inline code element",
        inline_code.replace("{.cpp}", "{.cpp .no_minted}"),
        r"\texttt{#include <type_traits>}"
    )
    verify(
        "[inline-code] default inline language is 'text'",
        inline_code.replace("{.cpp}", ""),
        mintinline.format(attrs="", lang="text")
    )
    verify(
        "[inline-code] user provided default_inline_language",
        textwrap.dedent('''
            ---
            minted:
              default_inline_language: "haskell"
            ---
            {inline_code}
        ''').format(inline_code=inline_code.replace("{.cpp}", "")),
        mintinline.format(attrs="", lang="haskell")
    )
    verify(
        "[inline-code] user provided inline_attributes",
        textwrap.dedent('''
            ---
            minted:
              inline_attributes:
                - "showspaces"
                - "space=."
            ---
            {inline_code}
        ''').format(inline_code=inline_code),
        mintinline.format(
            attrs=",".join(["showspaces", "space=."]), lang="cpp"
        )
    )
    verify(
        "[inline-code] attributes on inline code",
        inline_code.replace(
            "{.cpp}", "{.cpp .showspaces bgcolor=tango_bg style=tango}"
        ),
        mintinline.format(
            attrs=",".join(["showspaces", "bgcolor=tango_bg", "style=tango"]),
            lang="cpp"
        )
    )
    verify(
        "[inline-code] attributes on inline code + user inline_attributes",
        textwrap.dedent('''
            ---
            minted:
              inline_attributes:
                - "showspaces"
                - "space=."
            ---
            {inline_code}
        ''').format(
            inline_code=inline_code.replace(
                "{.cpp}", "{.cpp bgcolor=tango_bg style=tango}"
            )
        ),
        mintinline.format(
            attrs=",".join([
                "bgcolor=tango_bg",
                "style=tango",
                "showspaces",
                "space=."
            ]),
            lang="cpp"
        )
    )
    verify(
        "[inline-code] non-minted attributes not forwarded",
        inline_code.replace("{.cpp}", "{.cpp .showspaces .hello}"),
        mintinline.format(attrs="showspaces", lang="cpp")
    )


def run_html_tests(args):
    """
    Run tests with an html5 writer to make sure minted commands are not used.
    Also make sure minted specific attributes are indeed stripped.

    ``args`` (list of str)
        The base list of arguments to forward to pandoc.
    """
    def verify(test_name, md, attrs=[]):
        """Verify minted and any strings in attrs not produced"""
        output = run_pandoc(args + ["-t", "html5"], md)
        ensure_not_present(test_name, "mint", output)
        ensure_not_present(test_name, "fragile", output)
        if attrs:
            for a in attrs:
                ensure_not_present(test_name, a, output)
        # if `nil` is present, that likely means a problem parsing the metadata
        ensure_not_present(test_name, "nil", output)

    verify(r"[html] no \begin{minted}", code_block)
    verify(r"[html] no \mintinline", inline_code)
    verify(
        r"[html] no \begin{minted} or \mintinline",
        "{code_block}\n\n{inline_code}".format(
            code_block=code_block, inline_code=inline_code
        )
    )
    verify(
        "[html] code block minted specific attributes stripped",
        code_block.replace(
            "{.cpp}",
            "{.cpp .showspaces space=. bgcolor=minted_bg style=minted}"
        ),
        ["showspaces", "space", "bgcolor", "style"]
    )
    verify(
        "[html] inline code minted specific attributes stripped",
        inline_code.replace(
            "{.cpp}",
            "{.cpp .showspaces space=. bgcolor=minted_bg style=minted}"
        ),
        ["showspaces", "space", "bgcolor", "style"]
    )


if __name__ == "__main__":
    # Initial path setup for input tests and lua filter
    this_file_dir = os.path.abspath(os.path.dirname(__file__))
    minted_lua = os.path.join(this_file_dir, "minted.lua")
    if not os.path.isfile(minted_lua):
        sys.stderr.write("Cannot find '{minted_lua}'...".format(
            minted_lua=minted_lua
        ))
        sys.exit(1)

    args = ["--fail-if-warnings", "--lua-filter", minted_lua]
    run_tex_tests(args, "beamer")
    run_tex_tests(args, "latex")
    run_html_tests(args)
