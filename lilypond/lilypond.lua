if PANDOC_VERSION then
  PANDOC_VERSION:must_be_at_least({2, 7, 3})
else
  error("pandoc version >=2.7.3 is required")
end

local OPTIONS = {
        image_directory = ".",
        relativize = false
      }

local SPECIAL_CLASSES = {
        ["lilypond"] = true,
        ["ly-fragment"] = true,
        ["ly-norender"] = true
      }

local SPECIAL_ATTRIBUTES = {
        ["ly-caption"] = true,
        ["ly-name"] = true,
        ["ly-resolution"] = true,
        ["ly-title"] = true
      }

-- pandoc.system.with_temporary_directory had a different (undocumented)
-- name in the 2.7.3 release.
local with_temporary_directory = tostring(PANDOC_VERSION) == "2.7.3"
                                   and pandoc.system.with_temp_directory
                                    or pandoc.system.with_temporary_directory

-- This is the extra boilerplate that's added to code snippets when the
-- `ly-fragment' class is present. It's adapted from what `lilypond-book'
-- does. (The file `lilypond-book-preamble.ly' is placed on the include
-- path as part of the default LilyPond installation.)
local function wrap_fragment(src)
  return table.concat(
           {
             [[\include "lilypond-book-preamble.ly"]],
             [[\paper { indent = 0\mm }]],
             src,
           },
           "\n"
         )
end

local function get_output_directory()
  return PANDOC_STATE.output_file
           and pandoc.pipe(
                 "dirname",
                 {PANDOC_STATE.output_file},
                 ""
               ):gsub("\n", "")
end

local function resolve_relative_path(what, where)
  return pandoc.system.with_working_directory(
           where,
           function ()
             return pandoc.pipe("realpath", {what}, ""):gsub("\n", "")
           end
         )
end

local function generate_image(name, input, dpi, whither)
  local fullname = name .. ".png"
  with_temporary_directory(
    "lilypond-lua-XXXXX",
    function (tmp_dir)
      pandoc.system.with_working_directory(
        tmp_dir,
        function ()
          pandoc.pipe(
            "lilypond",
            {
              "--silent",
              "--png", dpi and "-dresolution=" .. dpi or "",
              "--output=" .. name, "-"
            },
            input
          )
          pandoc.pipe("cp", {fullname, whither}, "")
        end
      )
    end
  )
  return whither .. "/" .. fullname
end

function make_relative_path(to, from)
  return pandoc.pipe(
           "realpath",
           {"--relative-to=" .. from, to},
           ""
         ):gsub("\n", "")
end

local function process_lilypond(elem)
  if elem.classes:includes("lilypond") then
    if elem.classes:includes("ly-norender") then
      return elem
    end

    -- Are we dealing with an inline code element or a code block?
    local inline = elem.tag == "Code"

    local code = elem.text
    local fragment = elem.classes:includes("ly-fragment") or inline
    local input = fragment
                    and wrap_fragment(code)
                     or code
    local dpi = elem.attributes["ly-resolution"]
    local name = elem.attributes["ly-name"] or pandoc.sha1(code)

    local out_dir = get_output_directory() or "."
    local dest = resolve_relative_path(OPTIONS.image_directory, out_dir)

    local path = generate_image(name, input, dpi, dest)
    local img = io.open(path, "rb")
    pandoc.mediabag.insert(path, "image/png", img:read("*a"))
    img:close()

    local caption = elem.attributes["ly-caption"] or "Musical notation"
    local src = OPTIONS.relativize
                  and make_relative_path(path, out_dir)
                   or path
    -- The "fig:" prefix causes this image to be rendered as a proper figure
    -- in HTML ouput (this is a rather ugly pandoc feature and may be replaced
    -- by something more elegant in the future).
    local fudge = inline and "" or "fig:"
    -- Strip newlines, indendation, etc. from the code for a more readable title.
    local title = fudge .. (elem.attributes["ly-title"]
        `                     or code:gsub("%s+", " "))

    -- Strip most of the LilyPond-related attributes from this code element, for
    -- tidiness.
    local classes = elem.classes:filter(
      function (cls)
        return not SPECIAL_CLASSES[cls]
      end
    )
    table.insert(
      classes,
      -- Add one special class for styling/manipulation purposes.
      inline and "lilypond-image-inline"
              or "lilypond-image-standalone"
    )
    local attributes = elem.attributes
    for a, t in pairs(SPECIAL_ATTRIBUTES) do
      attributes[a] = nil
    end
    local attrs = pandoc.Attr(elem.identifier, classes, attributes)

    return pandoc.Image(caption, src, title, attrs)
  else
    return elem
  end
end

-- Update `OPTIONS' based on the document metadata. There's a bit of
-- munging because string options are parsed as (pandoc-flavored) Markdown
-- and we have to dig out the raw Lua string.
local function meta_transformer(md)
  local ly_block = md.lilypond or {}

  OPTIONS.image_directory = ly_block.image_directory
                              and ly_block.image_directory[1].text
                               or OPTIONS.image_directory
  OPTIONS.relativize = ly_block.relativize
                         or OPTIONS.relativize

  md.lilypond = nil
  return md
end

local function code_transformer(elem)
  return process_lilypond(elem)
end

-- When replacing a block element we must wrap the generated image in
-- a `Para' since `Image' is an inline element.
local function code_block_transformer(elem)
  return pandoc.Para({process_lilypond(elem)})
end

-- Make sure the metadata transformation runs first so that the code
-- transformations operate with the correct options.
return {
         {Meta = meta_transformer},
         {Code = code_transformer, CodeBlock = code_block_transformer},
       }
