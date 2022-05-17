# shortcodes

## Overview

Shortcodes are special markdown directives that generate various types of content. For example, the following shortcode prints the `title` from document metadata:

``` markdown
{{< meta title >}}
```

The `shortcodes.lua` filter supports several shortcodes natively:

| Shortcode                                    | Description                            |
|----------------------------------------------|----------------------------------------|
| `meta`                                       | Print value from document metadata     |
| `env`                                        | Print system environment variable      |
| `pagebreak`                                  | Insert a native page-break             |

In addition, you can create custom shortcodes (read on for details). 

## Shortcode Basics 

You can create your own shortcodes using Lua. Before working on custom shortcodes you should familiarize yourself with the documentation on [Pandoc Lua Filters](https://pandoc.org/lua-filters.html), which describes the Lua extension API for Pandoc.

Custom shortcodes are implemented as Lua functions that take one or more arguments and return a Pandoc AST node (or list of nodes).

Here's the implementation of the `env` shortcode:

**env.lua**

``` lua
function env(args)
  local var = pandoc.utils.stringify(args[1])
  local value = os.getenv(var)
  if value ~= nil then
    return pandoc.Str(value)
  else
    return pandoc.Null()
  end
end
```

Note that arguments to shortcodes are provided in `args` (a 1-based array), and that each argument is a list of Pandoc inlines (i.e. markdown AST parsed from the text).

We use the `pandoc.utils.stringify()` function to convert the inlines to an ordinary string, and then the `os.getenv()` function to get its value.

If this function was included in a source file named `env.lua`, you could register it for use with:

``` yaml
shortcodes:
  - env.lua
```

Then use it with:

``` markdown
{{< env HOME >}}
```

Below we'll provide a few a few more examples of custom shortcodes and their implementation.

## Example: Raw Output

Shortcodes can tailor their output to the format being rendered to. This is often useful when you want to conditionally generate rich HTML output but still have the same document render properly to PDF or MS Word.

The `pagebreak` shortcode generates "native" pagebreaks in a variety of formats. Here's the implementation of `pagebreak`:

**pagebreak.lua**

``` lua
function pagebreak()
 
  local raw = {
    epub = '<p style="page-break-after: always;"> </p>',
    html = '<div style="page-break-after: always;"></div>',
    latex = '\\newpage{}',
    ooxml = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>',
    odt = '<text:p text:style-name="Pagebreak"/>',
    context = '\\page'
  }

  if FORMAT == 'docx' then
    return pandoc.RawBlock('openxml', raw.ooxml)
  elseif FORMAT:match 'latex' then
    return pandoc.RawBlock('tex', raw.latex)
  elseif FORMAT:match 'odt' then
    return pandoc.RawBlock('opendocument', raw.odt)
  elseif FORMAT:match 'html.*' then
    return pandoc.RawBlock('html', raw.html)
  elseif FORMAT:match 'epub' then
    return pandoc.RawBlock('html', raw.epub)
  elseif FORMAT:match 'context' then
    return pandoc.RawBlock('context', raw.context)
  else
    -- fall back to insert a form feed character
    return pandoc.Para{pandoc.Str '\f'}
  end

end
```

We use the `pandoc.RawBlock()` function to output the appropriate raw content for the target `FORMAT`. Note that raw blocks are passed straight through to the output file and are not processed as markdown.

If this function was implemented within `pagebreak.lua`, you could register it for use with:

``` yaml
shortcodes:
  - pagebreak.lua
```

Then use it with:

``` markdown
{{< pagebreak >}}
```

## Example: Named Arguments

The examples above use either a single argument (`env`) or no arguments at all (`pagebreak`). Here we demonstrate named argument handling by implementing a `git-rev` shortcode that prints the current git revision, providing a `short` option to determine whether a short or long SHA1 is displayed:

**git.lua**

``` lua
-- run git and read its output
function git(command)
  local p = io.popen("git " .. command)
  local output = p:read('*all')
  p:close()
  return output
end

-- return a table containing shortcode definitions
-- defining shortcodes this way allows us to create helper 
-- functions that are not themselves considered shortcodes 
return {
  ["git-rev"] = function(args, kwargs)
    -- command line args
    local cmdArgs = ""
    local short = pandoc.utils.stringify(kwargs["short"])
    if short == "true" then
      cmdArgs = cmdArgs .. "--short "
    end
    
    -- run the command
    local cmd = "rev-parse " .. cmdArgs .. "HEAD"
    local rev = git(cmd)
    
    -- return as string
    return pandoc.Str(rev)
  end
}
```

There are some new things demonstrated here :

1.  Rather than defining our shortcode functions globally, we return a table with the shortcode definitions. This allows us to define helper functions that are not themselves registered as shortcodes. It also enables us to define a shortcode with a dash (`-`) in its name.

2.  There is a new argument to our shortcode handler: `kwargs`. This holds any named arguments to the shortcode. As with `args`, values in `kwargs` will always be a list of Pandoc inlines (allowing you to accept markdown as an argument). Since `short` is a simple boolean value we need to call `pandoc.utils.stringify()` to treat it as a string and then compare it to `"true"`.

We'd register and use this shortcode as follows:

``` markdown
---
title: "My Document"
shortcodes:
  - git.lua
---

{{< git-rev >}}
{{< git-rev short=true >}}
```

## Example: Metadata Options

In some cases you may want to provide options that affect how you shortcode behaves. There is a third argument to shortcode handlers (`meta`) that provides access to document and/or project level metadata.

Let's implement a different version of the `git-rev` shortcode that emits the revision as a link to GitHub rather than plain text. To do this we make use of `github.owner` and `github.repo` metadata values:

**git.lua**

``` lua
function git(command)
  local p = io.popen("git " .. command)
  local output = p:read('*all')
  p:close()
  return output
end

return {
  
  ["git-rev"] = function(args, kwargs, meta)
    -- run the command
    local rev = git("rev-parse HEAD")
    
    -- target repo
    local owner = pandoc.utils.stringify(meta["github.owner"])
    local repo = pandoc.utils.stringify(meta["github.repo"])
    local url = "https://github.com/" 
                .. owner .. "/" .. repo .. "/" .. rev 
    
    -- return as link
    return pandoc.Link(pandoc.Str(rev), url)
  end
}
```

As with `args` and `kwargs`, `meta` values are always provided as a list of Pandoc inlines so often need to be converted to string using `pandoc.utils.stringify()`.

To use this shortcode in a document we register it, provide the GitHub info as document options, then include the shortcode where we want the link to be:

``` markdown
---
title: "My Document"
shortcodes:
  - git.lua
github:
  owner: quarto-dev
  repo: quarto-cli
---

{{< git-rev >}}
```

The shortcode registration and GitHub metadata could just as well been provided in a project-level `_quarto.yml` file or a directory-level `_metadata.yml` file.

## Escaping 

If you are writing documentation about using variable shortcodes (for example, this article!) you might need to prevent them from being processed. You can do this in two ways:

1.  Escape the shortcode reference with extra braces like this:

    ``` markdown
    {{{< var version >}}}
    ```

2.  Add a `shortcodes=false` attribute to any code block you want to prevent processing of shortcodes within:

    ```` markdown
    ```{shortcodes=false}

    {{< var version >}}
    ```
    ````

