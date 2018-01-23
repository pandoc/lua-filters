function Span(elem)
    if elem.classes[1] == "comment-start" or elem.classes[1] == "comment-end" then
        return {}
    elseif elem.classes[1] == "insertion" then
        return elem.content
    elseif elem.classes[1] == "deletion" then
        return {}
    end
end