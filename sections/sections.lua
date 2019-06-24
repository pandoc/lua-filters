--- partition a document into HTML sections

function Pandoc(doc)
    local blocks = {}
    local stack = {0}

    local rawHtml = function(html)
        table.insert(blocks, pandoc.RawBlock("html", html))
    end

    for i, el in ipairs(doc.blocks) do
        if (el.t == "Header") then
            local level = el.c[1]
            while stack[#stack] >= level do
                table.remove(stack)
                rawHtml("</section>")
            end
            table.insert(stack, level)
            rawHtml("<section>")
        end
        table.insert(blocks, el)
    end

    for i = 2, #stack do
        rawHtml("</section>")
    end

    doc.blocks = blocks
    return doc
end
