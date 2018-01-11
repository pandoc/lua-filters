local function tikz2image(src, filetype, outfile)
    local tmp = os.tmpname()
    local tmpdir = string.match(tmp, "^(.*[\\/])") or "."
    local f = io.open(tmp .. ".tex", 'w')
    f:write("\\documentclass{standalone}\n\\usepackage{tikz}\n\\begin{document}\n")
    f:write(src)
    f:write("\n\\end{document}\n")
    f:close()
    local outp = pandoc.pipe('pdflatex', {'-interaction=batchmode','-output-directory',tmpdir,tmp}, "")
    if filetype == 'pdf' then
        os.rename(tmp .. ".pdf", outfile)
    else
        os.execute("convert " .. tmp .. ".pdf " .. outfile)
    end
    os.remove(tmp .. ".tex")
    os.remove(tmp .. ".pdf")
    os.remove(tmp .. ".log")
    os.remove(tmp .. ".aux")
end

extension_for = {
    html = 'png',
    html4 = 'png',
    html5 = 'png',
    latex = 'pdf',
    beamer = 'pdf' }

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function RawBlock(el)
    local filetype = extension_for[FORMAT] or "png"
    local fname = pandoc.sha1(el.text) .. "." .. filetype
    if not file_exists(fname) then
        tikz2image(el.text, filetype, fname)
    end
    return pandoc.Para({pandoc.Image({}, fname)})
end
