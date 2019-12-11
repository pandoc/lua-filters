PANDOC_VERSION
  and PANDOC_VERSION:must_be_at_least({2, 7, 3})
   or error("pandoc version >=2.3.7 is required")

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

local with_temporary_directory = tostring(PANDOC_VERSION) == "2.7.3"
                                   and pandoc.system.with_temp_directory
                                    or pandoc.system.with_temporary_directory

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
  local res
  pandoc.system.with_working_directory(
    where,
    function ()
      res = pandoc.pipe("realpath", {what}, ""):gsub("\n", "")
    end
  )
  return res
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

    local inline = elem.tag == "Code"

    local code = elem.text
    local fragment = elem.classes:includes("ly-fragment") or inline
    local input = fragment and wrap_fragment(code) or code
    local dpi = elem.attributes["ly-resolution"]
    local name = elem.attributes["ly-name"] or pandoc.sha1(code)

    local out_dir = get_output_directory() or "."
    local dest = resolve_relative_path(OPTIONS.image_directory, out_dir)

    local path = generate_image(name, input, dpi, dest)
    local img = io.open(path, "rb")
    pandoc.mediabag.insert(path, "image/png", img:read("*a"))
    img:close()

    local caption = elem.attributes["ly-caption"] or "Musical notation"
    local src = OPTIONS.relativize and make_relative_path(path, out_dir) or path
    local fudge = inline and "" or "fig:"
    local title = fudge .. (elem.attributes["ly-title"] or code)

    local classes = elem.classes:filter(
      function (cls)
        return not SPECIAL_CLASSES[cls]
      end
    )
    table.insert(
      classes,
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

local function meta_transformer(md)
  local ly_block = md.lilypond or {}
  for k, v in pairs(OPTIONS) do
    OPTIONS[k] = ly_block[k] or OPTIONS[k]
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
