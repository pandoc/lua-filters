if FORMAT ~= "latex" then
  return
end

local function latex(str)
  return pandoc.RawInline('latex', str)
end

function figure_image (elem)
  local image = elem.content and elem.content[1]
  return (image.t == 'Image' and image.title == 'fig:')
    and image
    or nil
end

function Para (para)
  local img = figure_image(para)
  if not img or not img.caption or not img.attributes['short-caption'] then
    return nil
  end

  local short_caption = pandoc.Span(
    pandoc.read(img.attributes['short-caption']).blocks[1].c
  )
  local hypertarget = "{%%\n"
  local label = "\n"
  if img.identifier ~= img.title then
    hypertarget = string.format("\\hypertarget{%s}{%%\n",img.identifier)
    label = string.format("\n\\label{%s}",img.identifier)
  end
  return pandoc.Para {
    latex(hypertarget .. "\\begin{figure}\n\\centering\n"),
    img,
    latex("\n\\caption["), short_caption, latex("]"), pandoc.Span(img.caption),
    latex(label .."\n\\end{figure}\n}\n")
  }
end
