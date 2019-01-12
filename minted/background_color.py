#!/usr/bin/env python

r"""
A simple script to print out the RGB ``\definecolor`` command for the background
color of a specified pygments style name.
"""

import sys
try:
    from pygments.styles import get_style_by_name
except ImportError as ie:
    sys.stderr.write("Please install the Pygments package:\n{0}\n".format(ie))
    sys.exit(1)


if __name__ == "__main__":
    # Make sure we have a style name provided.
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: {0} <style_name>\n\n".format(sys.argv[0]))
        sys.stderr.write("  Tip: run `pygmentize -L` to see style names.\n")
        sys.exit(1)

    # Grab the style object, error out if invalid name.
    style_name = sys.argv[1]
    try:
        style = get_style_by_name(style_name)
    except Exception as e:
        sys.stderr.write("Unable to find {0}:\n{1}\n".format(style_name, e))
        sys.exit(1)

    # Convert the hexadecimal string into rgb.
    background_hex = style.background_color.replace("#", "")
    if len(background_hex) != 6:
        sys.stderr.write("Unknown hex color: {0}\n".format(background_hex))
        sys.exit(1)

    try:
        r = int(background_hex[0:2], 16)
        g = int(background_hex[2:4], 16)
        b = int(background_hex[4:6], 16)
    except Exception as e:
        sys.stderr.write("Unable to convert to integers:\n{0}\n".format(e))
        sys.exit(1)

    # Build out the various options for \definecolor
    # All should be equivalent, but users may have a preference of one format
    # over another :p
    tex_color_name = "{0}_bg".format(style_name)
    def_HTML = r"\definecolor{{{0}}}{{HTML}}{{{1}}}".format(
        tex_color_name, background_hex.upper()
    )
    def_RGB = r"\definecolor{{{0}}}{{RGB}}{{{1}}}".format(
        tex_color_name, "{0},{1},{2}".format(r, g, b)
    )
    def_rgb = r"\definecolor{{{0}}}{{rgb}}{{{1}}}".format(
        tex_color_name,
        ",".join(["{0:.4}".format(float(c) / 255.0) for c in [r, g, b]])
    )

    # Enumerate the options
    print("Options for {0} (choose *one*):\n".format(style_name))
    print("  (*) {0}".format(def_HTML))
    print("  (*) {0}".format(def_RGB))
    print("  (*) {0}".format(def_rgb))

    # Make sure they know that `{style_name}_bg` can be changed to whatever
    # they want to be using in their document.
    notice = "{0}|{1}/".format(
        len(r"  (*) \definecolor{") * " ",
        (len(tex_color_name) - 2) * "-"
    )
    vline = notice[0:notice.find("|")+1]
    can_change = vline.replace("|", "+--> You can rename this too :)")
    print(notice)
    print(vline)
    print(can_change)
