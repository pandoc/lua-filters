--[[
    This Lua filter is used to create images with or without captions from
    code blocks. Currently PlantUML, GraphViz, Tikz, and Python can be
    processed. For further details, see README.md.

    Thanks to @floriandd2ba and @jgm for the initial implementation of
    the PlantUML filter, which I used as a template. Thanks also @muxueqz
    for the code to generate a GraphViz image.
]]

-- The PlantUML path. If set, uses the environment variable PLANTUML or the
-- value "plantuml.jar" (local PlantUML version). In order to define a
-- PlantUML version per pandoc document, use the meta data to define the key
-- "plantumlPath".
local plantumlPath = os.getenv("PLANTUML") or "plantuml.jar"

-- The Inkscape path. In order to define an Inkscape version per pandoc
-- document, use the meta data to define the key "inkscapePath".
local inkscapePath = os.getenv("INKSCAPE") or "inkscape"

-- The Python path. In order to define a Python version per pandoc document,
-- use the meta data to define the key "pythonPath".
local pythonPath = os.getenv("PYTHON")

-- The Python environment's activate script. Can be set on a per document
-- basis by using the meta data key "activatePythonPath".
local pythonActivatePath = os.getenv("PYTHON_ACTIVATE")

-- The Java path. In order to define a Java version per pandoc document,
-- use the meta data to define the key "javaPath".
local javaPath = os.getenv("JAVA_HOME")
if javaPath then
    javaPath = javaPath .. package.config:sub(1,1) .. "bin"
        .. package.config:sub(1,1) .. "java"
else
    javaPath = "java"
end

-- The dot (Graphviz) path. In order to define a dot version per pandoc
-- document, use the meta data to define the key "dotPath".
local dotPath = os.getenv("DOT") or "dot"

-- The pdflatex path. In order to define a pdflatex version per pandoc
-- document, use the meta data to define the key "pdflatexPath".
local pdflatexPath = os.getenv("PDFLATEX") or "pdflatex"

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
    plantumlPath = meta.plantumlPath or plantumlPath
    inkscapePath = meta.inkscapePath or inkscapePath
    pythonPath = meta.pythonPath or pythonPath
    pythonActivatePath = meta.activatePythonPath or pythonActivatePath
    javaPath = meta.javaPath or javaPath
    dotPath = meta.dotPath or dotPath
    pdflatexPath = meta.pdflatexPath or pdflatexPath
end

-- Call plantuml.jar with some parameters (cf. PlantUML help):
local function plantuml(puml, filetype)
    local final = pandoc.pipe(javaPath, {"-jar", plantumlPath, "-t" .. filetype, "-pipe", "-charset", "UTF8"}, puml)
    return final
end

-- Call dot (GraphViz) in order to generate the image
-- (thanks @muxueqz for this code):
local function graphviz(code, filetype)
    local final = pandoc.pipe(dotPath, {"-T" .. filetype}, code)
    return final
end

-- Compile LaTeX with Tikz code to an image:
local function tikz2image(src, filetype, additionalPackages)

    -- Define file names:
    local outfile = string.format("./tmp-latex/file.%s", filetype)
    local tmp = "./tmp-latex/file"
    local tmpDir = "./tmp-latex/"

    -- Ensure, that the tmp directory exists:
    os.execute("mkdir -p tmp-latex")

    -- Build and write the LaTeX document:
    local f = io.open(tmp .. ".tex", 'w')
    f:write("\\documentclass{standalone}\n\\usepackage{tikz}\n")

    -- Any additional package(s) are desired?
    if additionalPackages then
        f:write(additionalPackages)
    end

    f:write("\\begin{document}\n")
    f:write(src)
    f:write("\n\\end{document}\n")
    f:close()

    -- Execute the LaTeX compiler:
    pandoc.pipe(pdflatexPath, {'-output-directory', tmpDir, tmp}, '')

    -- Build the basic Inkscape command for the conversion:
    local baseCommand = " --without-gui --file=" .. tmp .. ".pdf"
    local knownFormat = false

    if filetype == "png" then

        -- Append the subcommands to convert into a PNG file:
        baseCommand = baseCommand .. " --export-png="
            .. tmp .. ".png --export-dpi=300"
        knownFormat = true

    elseif filetype == "svg" then

        -- Append the subcommands to convert into a SVG file:
        baseCommand = baseCommand .. " --export-plain-svg=" .. tmp .. ".svg"
        knownFormat = true

    end

    -- Unfortunately, continuation is only possible, if we know the actual
    -- format:
    if not knownFormat then
        error(string.format("Don't know how to convert pdf to %s.", filetype))
    end

    local imgData = nil

    -- We know the desired format. Thus, execute Inkscape:
    os.execute("\"" .. inkscapePath .. "\"" .. baseCommand)

    -- Try to open the image:
    local r = io.open(tmp .. "." .. filetype, 'rb')

    -- Read the image, if available:
    if r then
        imgData = r:read("*all")
        r:close()
    end

    -- Delete the image tmp file:
    os.remove(outfile)

    -- Remove the temporary files:
    os.remove(tmp .. ".tex")
    os.remove(tmp .. ".pdf")
    os.remove(tmp .. ".log")
    os.remove(tmp .. ".aux")

    return imgData
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
    local pycmd = pythonPath .. ' ' .. pyfile
    local command = pythonActivatePath
      and pythonActivatePath .. ' && ' .. pycmd
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
