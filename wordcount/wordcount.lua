-- counts words in a document 

words = 0 
characters = 0
characters_and_spaces = 0

wordcount = { 
  Str = function(el) 
    -- we don't count a word if it's entirely punctuation: 
    if el.text:match("%P") then 
        words = words + 1 
    end 
    characters = characters + utf8.len(el.text)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end, 

  Space = function(el)
    characters_and_spaces = characters_and_spaces + 1
  end,

  Code = function(el) 
    _,n = el.text:gsub("%S+","") 
    words = words + n 
    text_nospace = el.text:gsub("%s", "")
    characters = characters + utf8.len(text_nospace)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end, 

  CodeBlock = function(el) 
    _,n = el.text:gsub("%S+","") 
    words = words + n 
    text_nospace = el.text:gsub("%s", "")
    characters = characters + utf8.len(text_nospace)
    characters_and_spaces = characters_and_spaces + utf8.len(el.text)
  end 
} 

function Pandoc(el) 
    -- skip metadata, just count body: 
    pandoc.walk_block(pandoc.Div(el.blocks), wordcount) 
    print(words .. " words in body") 
    print(characters .. " characters in body")
    print(characters_and_spaces .. " characters in body (including spaces)")
    os.exit(0) 
end
