-- wrap images with a centering LaTeX snippet
-- https://tex.stackexchange.com/questions/46903/centering-with-includegraphics-not-with-beginfigure
function Image(elem)
  return {
		pandoc.RawInline('latex', '{\\centering'),
		elem,
		pandoc.RawInline('latex', '\\par}')
  }
end
