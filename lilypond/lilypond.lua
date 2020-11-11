if PANDOC_VERSION and PANDOC_VERSION.must_be_at_least then
  -- Actually, this check is redundant since `Version' objects were
  -- introduced in pandoc v2.7.3, but I've left it in for clarity.
  PANDOC_VERSION:must_be_at_least("2.7.3")
else
  error("pandoc version >=2.7.3 is required")
end

local OPTIONS = {
  image_directory = ".",
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

local function generate_image(name, input, dpi)
  local fullname = name .. ".png"
  return fullname, with_temporary_directory(
    "lilypond-lua-XXXXX",
    function (tmp_dir)
      return pandoc.system.with_working_directory(
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
          local fh = io.open(fullname, 'rb')
          local data = fh:read('*all')
          fh:close()
          return data
        end
      )
    end
  )
end

local function process_lilypond(elem, inline)
  local code = elem.text
  local fragment = elem.classes:includes("ly-fragment") or inline
  local input = fragment
                  and wrap_fragment(code)
                   or code
  local dpi = elem.attributes["ly-resolution"]
  local name = elem.attributes["ly-name"] or pandoc.sha1(code)

  local image_filename, image_data = generate_image(name, input, dpi)
  local src = OPTIONS.image_directory .. '/' .. image_filename
  pandoc.mediabag.insert(src, "image/png", image_data)

  local caption = elem.attributes["ly-caption"] or "Musical notation"
  -- The "fig:" prefix causes this image to be rendered as a proper figure
  -- in HTML ouput (this is a rather ugly pandoc feature and may be replaced
  -- by something more elegant in the future).
  local fudge = inline and "" or "fig:"
  -- Strip newlines, indendation, etc. from the code for a more readable title.
  local title = fudge .. (elem.attributes["ly-title"]
                            or code:gsub("%s+", " "))

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
end

-- Update `OPTIONS' based on the document metadata.
local function meta_transformer(md)
  local ly_block = md.lilypond or {}
  local dir_conf = ly_block.image_directory
  OPTIONS.image_directory = dir_conf
                              and pandoc.utils.stringify(dir_conf)
                               or OPTIONS.image_directory
  md.lilypond = nil
  return md
end

local function code_transformer(elem)
  if elem.classes:includes("lilypond")
       and not elem.classes:includes("ly-norender") then
    return process_lilypond(elem, true)
  else
    return elem
  end
end

local function code_block_transformer(elem)
  if elem.classes:includes("lilypond")
       and not elem.classes:includes("ly-norender") then
    -- When replacing a block element we must wrap the generated image
    -- in a `Para' since `Image' is an inline element.
    return pandoc.Para({process_lilypond(elem, false)})
  else
    return elem
  end
end

-- Make sure the metadata transformation runs first so that the code
-- transformations operate with the correct options.
return {
         {Meta = meta_transformer},
         {Code = code_transformer, CodeBlock = code_block_transformer},
       }
