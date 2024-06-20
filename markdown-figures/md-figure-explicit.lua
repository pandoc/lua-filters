--- Translate Divs with the "figure" class into Figure elements.
-- The contents of last child Div with the "caption" class will be used as the
-- figure caption.
function Div(div)

  local content = div.content
  local attr = div.attr
  local null_caption = {
    short = {},
    long = {}
  }

  if attr.classes:includes "figure" then

    local new_content =  pandoc.List({})

    -- A div with the caption class is captured as the figure's
    -- caption.
    for _,elem in pairs(div.content) do
      if elem.t == 'Div' then
        null_caption.long = elem.content
      else
        new_content:insert(elem)
      end
    end


    -- Remove the figure for `SimpleFigure` with no caption inside a Figure.
    local final_content = pandoc.List({})

    for _,elem in pairs(new_content) do
      -- Check that it is a simple figure with no caption
      if elem.t == 'Para' and 
        #elem.content == 1 and
        elem.content[1].t == 'Image' and
        #elem.content[1].caption == 0 then

        local image = elem.content[1]
        final_content:insert(pandoc.Plain({image}))
      else
        final_content:insert(elem)
      end
    end

    -- Remove the figure class in the output
    attr.classes = attr.classes:filter(
    function(c) return c ~= "figure" end)

    return pandoc.Figure(final_content, null_caption, attr)
  end

  -- Return an identical div when it lacks the "figure" class.
  return pandoc.Div(content, attr)
end
