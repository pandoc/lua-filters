
text = require 'text'

function toupper(args)
  return pandoc.walk_block(pandoc.Para(args[1]), {
    Str = function(el)
      el.text = text.upper(el.text)
      return el
    end
  }).content
end