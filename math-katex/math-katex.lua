--  VERSION 2022-01-04
--  DESCRIPTION
--
--  This Lua filter for Pandoc converts LaTeX math with katex for insertion into the
--  output document in a standalone manner. SVG output is in any of the available
--  MathJax fonts. This is useful for server-side rendering. No Internet connection
--  is required when generating or viewing formulas, resulting in both absolute
--  privacy and offline, standalone robustness.
--
--  REQUIREMENTS, USAGE & PRIVACY
--
--    See: https://github.com/pandoc/lua-filters/tree/master/math-katex
--
--    LICENSE
--
--    Copyright (c) 2020-2022 Benjamin Abel <dev.abel@free.fr>
--
--    MIT License
--
--    Permission is hereby granted, free of charge, to any person obtaining a
--    copy of this software and associated documentation files (the "Software"),
--    to deal in the Software without restriction, including without limitation
--    the rights to use, copy, modify, merge, publish, distribute, sublicense,
--    and/or sell copies of the Software, and to permit persons to whom the
--    Software is furnished to do so, subject to the following conditions:
--
--    The above copyright notice and this permission notice shall be included in
--    all copies or substantial portions of the Software.
--
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
--    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--    DEALINGS IN THE SOFTWARE.
--
--  The full path to the katex binary.
local katex_bin = 'katex'
local no_throw_on_error = false
local format = 'htmlAndMathml'

function Meta(meta)

    katex_bin = tostring(meta.math_katex_bin or katex_bin)
    no_throw_on_error = tostring(meta.math_katex_no_throw_on_error or no_throw_on_error)
    format = tostring(meta.math_katex_format or format)

end

function Math(elem)

    -- TODO handle macros with header-includes

    local argumentlist = {'--format', format, '--no-throw-on-error', no_throw_on_error}
    
    --  The available options for katex are:
    --  -V, --version                output the version number
    --  -d, --display-mode           Render math in display mode, which puts the math in display style (so \int and \sum are large, for
    --                               example), and centers the math on the page on its own line.
    --  -F, --format <type>          Determines the markup language of the output.
    --  --leqno                      Render display math in leqno style (left-justified tags).
    --  --fleqn                      Render display math flush left.
    --  -t, --no-throw-on-error      Render errors (in the color given by --error-color) instead of throwing a ParseError exception when
    --                               encountering an error.
    --  -c, --error-color <color>    A color string given in the format 'rgb' or 'rrggbb' (no #). This option determines the color of errors
    --                               rendered by the -t option.
    --  -m, --macro <def>            Define custom macro of the form '\foo:expansion' (use multiple -m arguments for multiple macros).
    --                               (default: [])
    --  --min-rule-thickness <size>  Specifies a minimum thickness, in ems, for fraction lines, `\sqrt` top lines, `{array}` vertical lines,
    --                               `\hline`, `\hdashline`, `\underline`, `\overline`, and the borders of `\fbox`, `\boxed`, and
    --                               `\fcolorbox`.
    --  -b, --color-is-text-color    Makes \color behave like LaTeX's 2-argument \textcolor, instead of LaTeX's one-argument \color mode
    --                               change.
    --  -S, --strict                 Turn on strict / LaTeX faithfulness mode, which throws an error if the input uses features that are not
    --                               supported by LaTeX.
    --  -T, --trust                  Trust the input, enabling all HTML features such as \url.
    --  -s, --max-size <n>           If non-zero, all user-specified sizes, e.g. in \rule{500em}{500em}, will be capped to maxSize ems.
    --                               Otherwise, elements and spaces can be arbitrarily large
    --  -e, --max-expand <n>         Limit the number of macro expansions to the specified number, to prevent e.g. infinite macro loops. If
    --                               set to Infinity, the macro expander will try to fully expand as in LaTeX.
    --  -f, --macro-file <path>      Read macro definitions, one per line, from the given file.
    --  -i, --input <path>           Read LaTeX input from the given file.
    --  -o, --output <path>          Write html output to the given file.
    --  -h, --help                   display help for command
    --  

    if (elem.mathtype == 'DisplayMath') then
        -- Add the --display-mode argument to the argument list.
        table.insert(argumentlist, 1, '--display-mode')
    end

    -- Generate markup.

    local markup = pandoc.pipe(katex_bin, argumentlist, elem.text)

    -- remove \n at the end https://github.com/KaTeX/KaTeX/blob/16b4bd9c0c315220d41a610c903e1701ca9c1042/cli.js#L99
    markup = markup:sub(1, -2)

    return pandoc.RawInline('html', markup)

end -- function

-- Redefining the execution order only in html
if FORMAT == "html" then
    return {{
        Meta = Meta
    }, {
        Math = Math
    }}
end
