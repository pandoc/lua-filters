
if FORMAT == "latex" then
   local function latex(str)
      return pandoc.RawInline('latex', str)
   end

   function Para (figure)
      if (#figure.content == 1) and (figure.content[1].t == 'Image')  and (figure.content[1].title == "fig:") then
         local img = figure.content[1]
         if img.caption and img.attributes['short-caption'] then
            local caption_cmd = string.format('\n\\caption[%s]',img.attributes['short-caption'])
            local name = img.c[1][1]
            local hypertarget = latex("{%%\n")
            local label = "\n"
            if name ~= "" then
               hypertarget = string.format("\\hypertarget{%s}{%%\n",name)
               label = string.format("\n\\label{%s}",name)
            end
            return pandoc.Para {
               latex(hypertarget .. "\\begin{figure}\n\\centering\n"),
               img,
               latex(caption_cmd),
               pandoc.Span(img.caption),
               latex(label .."\n\\end{figure}\n}\n")
            }
         end
      end
   end
end
