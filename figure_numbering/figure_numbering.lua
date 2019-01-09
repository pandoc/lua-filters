-- The first image is the first image ;-)
local nextNumber = 1

-- The default figure's caption prefix is 'Fig.':
local prefix_caption = "Fig."

-- The default figure's text prefix is 'Figure':
local prefix_text = "Figure"

-- All known images with their names and current number.
-- e.g. "img:important-class1" -> "Figure 16"
local knownImageNames = {}

-- Local function the check the ending of a string:
local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

-- Execute the meta data table to determine the image prefix. This function
-- must be called first to get the desired prefix.
function Meta(meta)
    if meta.figure_prefix_caption then
        prefix_caption = meta.figure_prefix_caption
    end

    if meta.figure_prefix_text then
        prefix_text = meta.figure_prefix_text
    end
end

-- Execute each image block in order to number it and to prepare the replacement
-- of corresponding image names in the document.
function Image(block)

    -- Does this image has a caption?
    if block.caption[1] then

        -- Read the current caption i.e. without the prefix and number:
        local currentCaption = block.caption[1].text

        -- Build the new caption i.e. with prefix and number:
        local newCaption = string.format("%s %d: %s", prefix_caption, nextNumber, currentCaption)

        -- Overwrite the current caption with the new one:
        block.caption[1].text = newCaption
    end

    -- Does this image defines a name for references in the document?
    if block.attributes["name"] then

        -- Store the desired name and its replacement i.e. "img:important-class1" -> "Figure 16":
        knownImageNames[string.format("%s", block.attributes["name"])] = string.format("%s %d", prefix_text, nextNumber)
    end

    -- We count all images, regardless their caption usage i.e. increment for each image:
    nextNumber = nextNumber + 1

    -- Return the image block:
    return block
end

-- Execute each inline element of the entire document in order to replace image references with their numbers:
function Inline(element)

    if element.text then

        -- Store the inline text:
        local inline_text = element.text

        -- Store the inline text without the last character i.e. without its potentially ending:
        local inline_text_without_last = element.text:sub(1, -2)

        -- Do we know this element's text as placeholder i.e. image name? Case: The placeholder stand alone i.e. 'img:one':
        if knownImageNames[inline_text] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[element.text])

        -- Does this text ends with ',' and do we know this text i.e. placeholder as image name? Case: The placeholder ends with ',' i.e. 'img:one,':
        elseif ends_with(inline_text, ",") and knownImageNames[inline_text_without_last] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[inline_text_without_last] .. ",")

        -- Does this text ends with '.' and do we know this text i.e. placeholder as image name? Case: The placeholder ends with '.' i.e. 'img:one.':
        elseif ends_with(inline_text, ".") and knownImageNames[inline_text_without_last] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[inline_text_without_last] .. ".")

        -- Does this text ends with '!' and do we know this text i.e. placeholder as image name? Case: The placeholder ends with '!' i.e. 'img:one!':
        elseif ends_with(inline_text, "!") and knownImageNames[inline_text_without_last] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[inline_text_without_last] .. "!")

        -- Does this text ends with ';' and do we know this text i.e. placeholder as image name? Case: The placeholder ends with ';' i.e. 'img:one;':
        elseif ends_with(inline_text, ";") and knownImageNames[inline_text_without_last] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[inline_text_without_last] .. ";")

        -- Does this text ends with '…' and do we know this text i.e. placeholder as image name? Case: The placeholder ends with '…' i.e. 'img:one…':
        elseif ends_with(inline_text, "…") and knownImageNames[inline_text_without_last] then

            -- Yes, we do. Replace the inline element with the desired text i.e. prefix and number:
            return pandoc.Span(knownImageNames[inline_text_without_last] .. "…")
        end
    end
end

-- Normally, pandoc will run the function in the built-in order Inlines -> Blocks -> Meta -> Pandoc.
-- We instead want Meta -> Blocks -> Inlines. Thus, we have to define our custom order:
return {
    {Meta = Meta},
    {Image = Image},
    {Inline = Inline},
}