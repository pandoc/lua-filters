PANDOC_VERSION:must_be_at_least({2,7,3})

local DEFAULTS = {
    fragment = false,
    norender = false,
    caption = "musical notation",
    extra_code = "",
    image_directory = ".",
    name = false,
    relativize = false,
    title = false
  }

local SPECIAL_CLASSES = {
    "lilypond",
    "ly-fragment",
    "ly-norender"
  }

local SPECIAL_ATTRIBUTES = {
    "ly-caption",
    "ly-image-directory",
    "ly-name",
    "ly-relativize",
    "ly-title"
  }

local with_temporary_directory = tostring(PANDOC_VERSION) == "2.7.3"
                                 and pandoc.system.with_temp_directory
                                 or pandoc.system.with_temporary_directory

local function wrap_fragment(src)
  return table.concat({
      [[\include "lilypond-book-preamble.ly"]],
      [[\paper { indent = 0\mm }]],
      [[\layout {}]],
      [[{ \sourcefileline 0]],
      src,
      [[}]]
    }, "\n")
end

local function process_lilypond(elem)
  if elem.classes:includes("lilypond") then
    local norender = elem.classes:includes("ly-norender")
                     or DEFAULTS.norender
    if norender then
      return elem
    end

    local code = elem.text
    local fragment = elem.classes:includes("ly-fragment")
                     or DEFAULTS.fragment
    local input = fragment and wrap_fragment(code) or code

    local caption = elem.attributes["ly-caption"]
                    or DEFAULTS.caption
    local img_raw_dir = elem.attributes["ly-image-directory"]
                        or DEFAULTS.image_directory
    local name = elem.attributes["ly-name"]
                 or pandoc.sha1(input)  -- `name' can't be defaulted
    local relativize = elem.attributes["ly-relativize"]
                       or DEFAULTS.relativize
    local title = elem.attributes["ly-title"]
                  or code  -- likewise `title'

    local out_dir = PANDOC_STATE.output_file
                    and pandoc.pipe("dirname", {PANDOC_STATE.output_file}, ""):gsub("\n", "")
                    or "."
    local img_dir
    pandoc.system.with_working_directory(out_dir,
      function ()
        img_dir = pandoc.pipe("realpath", {img_raw_dir}, "")
        img_dir = img_dir:gsub("\n", "")
      end
    )

    local filename = name .. ".png"
    local img_path = img_dir .. "/" .. filename
    with_temporary_directory("lilypond-lua-XXXXX",
      function (tmp_dir)
        pandoc.system.with_working_directory(tmp_dir,
          function ()
            pandoc.pipe("lilypond", {
                "--silent", "--png", "--output=" .. name, "-"
              }, input)
            pandoc.pipe("cp", {filename, img_path}, "")
          end
        )
      end
    )

    local img_file = io.open(img_path, "rb")
    pandoc.mediabag.insert(img_path, "image/png", img_file:read("*a"))
    img_file:close()

    local img_classes = elem.classes:filter(
      function (cls)
        return not SPECIAL_CLASSES[cls]
      end
    )
    img_classes:extend("lilypond-image")
    local img_attributes = elem.attributes
    for i, a in ipairs(SPECIAL_ATTRIBUTES) do
      img_attributes[a] = nil
    end
    local img_attrs = pandoc.Attr(elem.identifier, img_classes, img_attributes)

    local img_src = relativize
                    and pandoc.pipe("realpath", {
                            "--relative-to=" .. out_dir, img_path
                          }, ""):gsub("\n", "")
                    or img_path

    return pandoc.Image(caption, img_src, title, remaining_attrs)
  else
    return elem
  end
end

local function meta_transformer(md)
  local ly_block = md.lilypond
  for k, v in pairs(DEFAULTS) do
    DEFAULTS[k] = ly_block[k] or DEFAULTS[k]
  end
  md.lilypond = nil
  return md
end

local function code_transformer(elem)
  return process_lilypond(elem)
end

local function code_block_transformer(elem)
  return pandoc.Para({process_lilypond(elem)})
end

return {
    {Meta = meta_transformer},
    {Code = code_transformer, CodeBlock = code_block_transformer},
  }
