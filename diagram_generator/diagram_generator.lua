--[[
    This Lua filter is used to create images with or without captions from
    code blocks. Currently PlantUML, GraphViz, Tikz, and Python can be
    processed. For further details, see README.md.

    Thanks to @floriandd2ba and @jgm for the initial implementation of
    the PlantUML filter, which I used as a template. Thanks also @muxueqz
    for the code to generate a GraphViz image.
]]

-- The PlantUML path. If set, uses the environment variable PLANTUML or the value "plantuml.jar" (local PlantUML version).
-- In order to define a PlantUML version per pandoc document, use the meta data to define the key "plantuml_path".
local plantumlPath = os.getenv("PLANTUML") or "plantuml.jar"

-- The Inkscape path. In order to define an Inkscape version
-- per pandoc document, use the meta data to define the key "inkscape_path".
local inkscapePath = os.getenv("INKSCAPE") or "inkscape"

-- The Python path. In order to define a Python version per pandoc document,
-- use the meta data to define the key "python_path".
local pythonPath = os.getenv("PYTHON") or "python"

-- The Python environment's activate script. Can be set on a per document basis
-- by using the meta data key "activate_python_path".
local pythonActivatePath = os.getenv("PYTHON_ACTIVATE")

-- The Java path. In order to define a Java version per pandoc document,
-- use the meta data to define the key "java_path".
local javaPath = os.getenv("JAVA_HOME")
if javaPath then
    javaPath = javaPath .. package.config:sub(1,1) .. "bin" .. package.config:sub(1,1) .. "java"
else
    javaPath = "java"
end

-- The dot (Graphviz) path. In order to define a dot version per pandoc document,
-- use the meta data to define the key "dot_path".
local dotPath = os.getenv("DOT") or "dot"

-- The pdflatex path. In order to define a pdflatex version per pandoc document,
-- use the meta data to define the key "pdflatex_path".
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
    if meta.plantuml_path then
        plantumlPath = meta.plantuml_path
    end

    if meta.inkscape_path then
        inkscapePath = meta.inkscape_path
    end

    if meta.python_path then
        pythonPath = meta.python_path
    end

    if meta.activate_python_path then
        pythonActivatePath = meta.activate_python_path
    end

    if meta.java_path then
        javaPath = meta.java_path
    end

    if meta.dot_path then
        dotPath = meta.dot_path
    end

    if meta.pdflatex_path then
        pdflatexPath = meta.pdflatex_path
    end
end

-- Call plantuml.jar with some parameters (cf. PlantUML help):
local function plantuml(puml, filetype, plantumlPath)
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
local function tikz2image(src, filetype)

    -- Define file names:
    local outfile = string.format("./tmp-latex/file.%s", filetype)
    local tmp = "./tmp-latex/file"
    local tmpDir = "./tmp-latex/"

    -- Ensure, that the tmp directory exists:
    os.execute("mkdir tmp-latex")

    -- Build and write the LaTeX document:
    local f = io.open(tmp .. ".tex", 'w')
    f:write("\\documentclass{standalone}\n\\usepackage{tikz}\n\\begin{document}\n")
    f:write(src)
    f:write("\n\\end{document}\n")
    f:close()

    -- Execute the LaTeX compiler:
    os.execute(pdflatexPath .. " -output-directory " .. tmpDir .. " " .. tmp)

    -- Build the basic Inkscape command for the conversion:
    local baseCommand = " --without-gui --file=" .. tmp .. ".pdf"
    local knownFormat = false

    if filetype == "png" then
        
        -- Append the subcommands to convert into a PNG file:
        baseCommand = baseCommand .. " --export-png=" .. tmp .. ".png --export-dpi=300"
        knownFormat = true

    elseif filetype == "svg" then
        
        -- Append the subcommands to convert into a SVG file:
        baseCommand = baseCommand .. "--export-plain-svg=" .. tmp .. ".svg"
        knownFormat = true

    end

    -- Unfortunately, continuation is only possible, if we know the actual format:
    local img_data = nil
    if knownFormat then

        -- We know the desired format. Thus, execute Inkscape:
        os.execute("\"" .. inkscapePath .. "\"" .. baseCommand)
        
        -- Try to open the image:
        local r = io.open(tmp .. "." .. filetype, 'rb')
        
        -- Read the image, if available:
        if r then
            img_data = r:read("*all")
            r:close()
        end
        
        -- Delete the image tmp file:
        os.remove(outfile)
    end

    -- Remove the temporary files:
    os.remove(tmp .. ".tex")
    os.remove(tmp .. ".pdf")
    os.remove(tmp .. ".log")
    os.remove(tmp .. ".aux")

    return img_data
end

-- Run Python to generate an image:
local function py2image(code, filetype)
    
    -- Define the temp files:
    local outfile = string.format("./tmp-python/file.%s", filetype)
    local tmp = "./tmp-python/file"
    local tmpDir = "./tmp-python/"

    -- Replace the desired destination's file type in the Python code:
    local extendedCode = string.gsub(code, "%$FORMAT%$", filetype)

    -- Replace the desired destination's path in the Python code:
    extendedCode = string.gsub(extendedCode, "%$DESTINATION%$", outfile)

    -- Ensure, that the tmp directory exists:
    os.execute("mkdir tmp-python")

    -- Write the Python code:
    local f = io.open(tmp .. ".py", 'w')
    f:write(extendedCode)
    f:close()

    -- Execute Python in the desired environment:
    os.execute(pythonActivatePath .. " && " .. pythonPath .. " " .. tmp .. ".py")

    -- Try to open the written image:
    local r = io.open(outfile, 'rb')
    local img_data = nil

    -- When the image exist, read it:
    if r then
        img_data = r:read("*all")
        r:close()
    end

    -- Delete the tmp files:
    os.remove(tmp .. ".py")
    os.remove(outfile)

    return img_data
end

-- Executes each document's code block to find matching code blocks:
function CodeBlock(block)

    -- Predefine a potential image:
    local fname = nil

    -- Filter code blocks which codes we support:
    if block.classes[1] == "plantuml" then

        -- Generate the PlantUML diagram and store the yielded graphics in the media bag:
        local img = plantuml(block.text, filetype, plantumlPath)
        if img then
            fname = pandoc.sha1(img) .. "." .. filetype
            pandoc.mediabag.insert(fname, mimetype, img)
        end

    elseif block.classes[1] == "graphviz" then

        -- Generate the dot diagram and store the yielded graphics in the media bag:
        local img = graphviz(block.text, filetype)
        if img then
            fname = pandoc.sha1(img) .. "." .. filetype
            pandoc.mediabag.insert(fname, mimetype, img)
        end

    elseif block.classes[1] == "tikz" then

        -- Generate the Tikz diagram and store it in the media bag:
        local img = tikz2image(block.text, filetype)
        if img then
            fname = pandoc.sha1(img) .. "." .. filetype
            pandoc.mediabag.insert(fname, mimetype, img)
        end

    elseif block.classes[1] == "py2image" then

        -- Generate the Python diagram and store it in the media bag:
        local img = py2image(block.text, filetype)
        if img then
            fname = pandoc.sha1(img) .. "." .. filetype
            pandoc.mediabag.insert(fname, mimetype, img)
        end

    end

    -- Case: This code block was an image e.g. PlantUML or dot/Graphviz, etc.:
    if fname then

        -- Define the default caption:
        local caption = {}
        local enable_caption = nil

        -- If the user defines a caption, use it:
        if block.attributes["caption"] then
            caption = pandoc.Str(block.attributes["caption"])

            -- This is pandoc's current hack to enforce a caption:
            enable_caption = "fig:"
        end

        -- Create a new image for the document's structure. Attach the user's caption.
        -- Also use a hack (fig:) to enforce pandoc to create a figure i.e. attach
        -- a caption to the image.
        local imgObj = pandoc.Image(caption, fname, enable_caption)

        -- Now, transfer the attribute "name" from the code block to the new image block.
        -- It might gets used by the figure numbering lua filter. If the figure numbering
        -- gets not used, this additional attribute gets ignored as well.
        if block.attributes["name"] then
            imgObj.attributes["name"] = block.attributes["name"]
        end

        -- Finally, put the image inside an empty paragraph. By returning the resulting
        -- paragraph object, the source code block gets replaced by the image:
        return pandoc.Para{ imgObj }
    end
end

-- Normally, pandoc will run the function in the built-in order Inlines -> Blocks -> Meta -> Pandoc.
-- We instead want Meta -> Blocks. Thus, we must define our custom order:
return {
    {Meta = Meta},
    {CodeBlock = CodeBlock},
}