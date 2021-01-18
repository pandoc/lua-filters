--[[
diagram-generator – create images and figures from code blocks.

This Lua filter is used to create images with or without captions
from code blocks. Currently PlantUML, GraphViz, Tikz, and Python
can be processed. For further details, see README.md.

Copyright: © 2018-2020 John MacFarlane <jgm@berkeley.edu>,
             2018 Florian Schätzig <florian@schaetzig.de>,
             2019 Thorsten Sommer <contact@sommer-engineering.com>,
             2019-2020 Albert Krewinkel <albert+pandoc@zeitkraut.de>
License:   MIT – see LICENSE file for details
]]
-- Module pandoc.system is required and was added in version 2.7.3
PANDOC_VERSION:must_be_at_least '2.7.3'

local system = require 'pandoc.system'
local utils = require 'pandoc.utils'
local stringify = utils.stringify
local with_temporary_directory = system.with_temporary_directory
local with_working_directory = system.with_working_directory

-- The PlantUML path. If set, uses the environment variable PLANTUML or the
-- value "plantuml.jar" (local PlantUML version). In order to define a
-- PlantUML version per pandoc document, use the meta data to define the key
-- "plantuml_path".
local plantuml_path = os.getenv("PLANTUML") or "plantuml.jar"

-- The Inkscape path. In order to define an Inkscape version per pandoc
-- document, use the meta data to define the key "inkscape_path".
local inkscape_path = os.getenv("INKSCAPE") or "inkscape"

-- The Python path. In order to define a Python version per pandoc document,
-- use the meta data to define the key "python_path".
local python_path = os.getenv("PYTHON") or "python"

-- The Python environment's activate script. Can be set on a per document
-- basis by using the meta data key "activatePythonPath".
local python_activate_path = os.getenv("PYTHON_ACTIVATE")

-- The Java path. In order to define a Java version per pandoc document,
-- use the meta data to define the key "java_path".
local java_path = os.getenv("JAVA_HOME")
if java_path then
    java_path = java_path .. package.config:sub(1,1) .. "bin"
        .. package.config:sub(1,1) .. "java"
else
    java_path = "java"
end

-- The dot (Graphviz) path. In order to define a dot version per pandoc
-- document, use the meta data to define the key "dot_path".
local dot_path = os.getenv("DOT") or "dot"

-- The pdflatex path. In order to define a pdflatex version per pandoc
-- document, use the meta data to define the key "pdflatex_path".
local pdflatex_path = os.getenv("PDFLATEX") or "pdflatex"

-- The asymptote path. There is also the metadata variable
-- "asymptote_path".
local asymptote_path = os.getenv ("ASYMPTOTE") or "asy"

-- The default format is SVG i.e. vector graphics:
local filetype = "svg"
local mimetype = "image/svg+xml"

-- Check for output formats that potentially cannot use SVG
-- vector graphics. In these cases, we use a different format
-- such as PNG:
if FORMAT == "docx" then
    filetype = "png"
    mimetype = "image/png"
elseif FORMAT == "pptx" then
    filetype = "png"
    mimetype = "image/png"
elseif FORMAT == "rtf" then
    filetype = "png"
    mimetype = "image/png"
end

-- Execute the meta data table to determine the paths. This function
-- must be called first to get the desired path. If one of these
-- meta options was set, it gets used instead of the corresponding
-- environment variable:
function Meta(meta)
  plantuml_path = stringify(
    meta.plantuml_path or meta.plantumlPath or plantuml_path
  )
  inkscape_path = stringify(
    meta.inkscape_path or meta.inkscapePath or inkscape_path
  )
  python_path = stringify(
    meta.python_path or meta.pythonPath or python_path
  )
  python_activate_path =
    meta.activate_python_path or meta.activatePythonPath or python_activate_path
  python_activate_path = python_activate_path and stringify(python_activate_path)
  java_path = stringify(
    meta.java_path or meta.javaPath or java_path
  )
  dot_path = stringify(
    meta.path_dot or meta.dotPath or dot_path
  )
  pdflatex_path = stringify(
    meta.pdflatex_path or meta.pdflatexPath or pdflatex_path
  )
  asymptote_path = stringify(
     meta.asymptote_path or meta.asymptotePath or asymptote_path
  )
end

-- Call plantuml.jar with some parameters (cf. PlantUML help):
local function plantuml(puml, filetype)
  return pandoc.pipe(
    java_path,
    {"-jar", plantuml_path, "-t" .. filetype, "-pipe", "-charset", "UTF8"},
    puml
  )
end

-- Call dot (GraphViz) in order to generate the image
-- (thanks @muxueqz for this code):
local function graphviz(code, filetype)
  return pandoc.pipe(dot_path, {"-T" .. filetype}, code)
end

--
-- TikZ
--

--- LaTeX template used to compile TikZ images. Takes additional
--- packages as the first, and the actual TikZ code as the second
--- argument.
local tikz_template = [[
\documentclass{standalone}
\usepackage{tikz}
%% begin: additional packages
%s
%% end: additional packages
\begin{document}
%s
\end{document}
]]

-- Returns a function which takes the filename of a PDF or SVG file
-- and a target filename, and writes the input as the given format.
-- Returns `nil` if conversion into the target format is not possible.
local function convert_with_inkscape(filetype)
  -- Build the basic Inkscape command for the conversion
  local inkscape_output_args
  if filetype == 'png' then
    inkscape_output_args = '--export-png="%s" --export-dpi=300'
  elseif filetype == 'svg' then
    inkscape_output_args = '--export-plain-svg="%s"'
  else
    return nil
  end
  return function (pdf_file, outfile)
    local inkscape_command = string.format(
      '"%s" --without-gui --file="%s" ' .. inkscape_output_args,
      inkscape_path,
      pdf_file,
      outfile
    )
    io.stderr:write(inkscape_command .. '\n')
    local command_output = io.popen(inkscape_command)
    -- TODO: print output when debugging.
    command_output:close()
  end
end

--- Compile LaTeX with Tikz code to an image
local function tikz2image(src, filetype, additional_packages)
  local convert = convert_with_inkscape(filetype)
  -- Bail if there is now known way from PDF to the target format.
  if not convert then
    error(string.format("Don't know how to convert pdf to %s.", filetype))
  end
  return with_temporary_directory("tikz2image", function (tmpdir)
    return with_working_directory(tmpdir, function ()
      -- Define file names:
      local file_template = "%s/tikz-image.%s"
      local tikz_file = file_template:format(tmpdir, "tex")
      local pdf_file = file_template:format(tmpdir, "pdf")
      local outfile = file_template:format(tmpdir, filetype)

      -- Build and write the LaTeX document:
      local f = io.open(tikz_file, 'w')
      f:write(tikz_template:format(additional_packages or '', src))
      f:close()

      -- Execute the LaTeX compiler:
      pandoc.pipe(pdflatex_path, {'-output-directory', tmpdir, tikz_file}, '')

      convert(pdf_file, outfile)

      -- Try to open and read the image:
      local img_data
      local r = io.open(outfile, 'rb')
      if r then
        img_data = r:read("*all")
        r:close()
      else
        -- TODO: print warning
      end

      return img_data
    end)
  end)
end

-- Run Python to generate an image:
local function py2image(code, filetype)

    -- Define the temp files:
    local outfile = string.format('%s.%s', os.tmpname(), filetype)
    local pyfile = os.tmpname()

    -- Replace the desired destination's file type in the Python code:
    local extendedCode = string.gsub(code, "%$FORMAT%$", filetype)

    -- Replace the desired destination's path in the Python code:
    extendedCode = string.gsub(extendedCode, "%$DESTINATION%$", outfile)

    -- Write the Python code:
    local f = io.open(pyfile, 'w')
    f:write(extendedCode)
    f:close()

    -- Execute Python in the desired environment:
    local pycmd = python_path .. ' ' .. pyfile
    local command = python_activate_path
      and python_activate_path .. ' && ' .. pycmd
      or pycmd
    os.execute(command)

    -- Try to open the written image:
    local r = io.open(outfile, 'rb')
    local imgData = nil

    -- When the image exist, read it:
    if r then
        imgData = r:read("*all")
        r:close()
    else
        io.stderr:write(string.format("File '%s' could not be opened", outfile))
        error 'Could not create image from python code.'
    end

    -- Delete the tmp files:
    os.remove(pyfile)
    os.remove(outfile)

    return imgData
end

--
-- Asymptote
--

local function asymptote(code, filetype)
  local convert
  if filetype ~= 'svg' and filetype ~= 'png' then
    error(string.format("Conversion to %s not implemented", filetype))
  end
  return with_temporary_directory(
    "asymptote",
    function(tmpdir)
      return with_working_directory(
        tmpdir,
        function ()
          local asy_file = "pandoc_diagram.asy"
          local svg_file = "pandoc_diagram.svg"
          local f = io.open(asy_file, 'w')
          f:write(code)
          f:close()

          pandoc.pipe(asymptote_path, {"-f", "svg", "-o", "pandoc_diagram", asy_file}, "")

          local r
          if filetype == 'svg' then
            r = io.open(svg_file, 'rb')
          else
            local png_file = "pandoc_diagram.png"
            convert_with_inkscape("png")(svg_file, png_file)
            r = io.open(png_file, 'rb')
          end

          local img_data
          if r then
            img_data = r:read("*all")
            r:close()
          else
            error("could not read asymptote result file")
          end
          return img_data
      end)
  end)
end

-- Executes each document's code block to find matching code blocks:
function CodeBlock(block)

    -- Predefine a potential image:
    local fname = nil

    -- Using a table with all known generators i.e. converters:
    local converters = {
        plantuml = plantuml,
        graphviz = graphviz,
        tikz = tikz2image,
        py2image = py2image,
        asymptote = asymptote,
    }

    -- Check if a converter exists for this block. If not, return the block
    -- unchanged.
    local img_converter = converters[block.classes[1]]
    if not img_converter then
      return nil
    end

    -- Call the correct converter which belongs to the used class:
    local success, img = pcall(img_converter, block.text,
        filetype, block.attributes["additionalPackages"] or nil)

    -- Was ok?
    if success and img then
        -- Hash the figure name and content:
        fname = pandoc.sha1(img) .. "." .. filetype

        -- Store the data in the media bag:
        pandoc.mediabag.insert(fname, mimetype, img)

    else

        -- an error occured; img contains the error message
        io.stderr:write(tostring(img))
        io.stderr:write('\n')
        error 'Image conversion failed. Aborting.'

    end

    -- Case: This code block was an image e.g. PlantUML or dot/Graphviz, etc.:
    if fname then

        -- Define the default caption:
        local caption = {}
        local enableCaption = nil

        -- If the user defines a caption, use it:
        if block.attributes["caption"] then
            caption = pandoc.read(block.attributes.caption).blocks[1].content

            -- This is pandoc's current hack to enforce a caption:
            enableCaption = "fig:"
        end

        -- Create a new image for the document's structure. Attach the user's
        -- caption. Also use a hack (fig:) to enforce pandoc to create a
        -- figure i.e. attach a caption to the image.
        local imgObj = pandoc.Image(caption, fname, enableCaption)

        -- Now, transfer the attribute "name" from the code block to the new
        -- image block. It might gets used by the figure numbering lua filter.
        -- If the figure numbering gets not used, this additional attribute
        -- gets ignored as well.
        if block.attributes["name"] then
            imgObj.attributes["name"] = block.attributes["name"]
        end
    
        -- Transfer the identifier from the code block to the new image block
        -- to enable downstream filters like pandoc-crossref. This allows a figure
        -- block starting with:
        --
        --     ```{#fig:pumlExample .plantuml caption="This is an image, created by **PlantUML**."}
        --
        -- to be referenced as @fig:pumlExample outside of the figure.
        if block.identifier then
            imgObj.identifier = block.identifier
        end

        -- Finally, put the image inside an empty paragraph. By returning the
        -- resulting paragraph object, the source code block gets replaced by
        -- the image:
        return pandoc.Para{ imgObj }
    end
end

-- Normally, pandoc will run the function in the built-in order Inlines ->
-- Blocks -> Meta -> Pandoc. We instead want Meta -> Blocks. Thus, we must
-- define our custom order:
return {
    {Meta = Meta},
    {CodeBlock = CodeBlock},
}
