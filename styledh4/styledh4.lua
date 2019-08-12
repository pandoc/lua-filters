-- replace a markdown 4 level header with a custom tag for styling
function Header(elem)
	if elem.level == 4 then
		-- convert the header content to a string so we can
		-- interpolate with raw LaTeX
		local content_str = pandoc.utils.stringify(elem.content)
		-- https://en.wikibooks.org/wiki/LaTeX/Paragraph_Formatting#Paragraph_line_break
		return pandoc.RawBlock('latex', '\\textbf{' .. content_str .. '}  ~\\')
	end

	return nil
end
