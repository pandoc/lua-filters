local function is_numberlines_class(class)
    return class == 'numberLines' or class == 'number-lines'
end

local function is_pre_tag_attribute(attribute) return attribute == 'data-id' end

local function is_data_line_number_in_attributes(attributes)
    for _, attribute in ipairs(attributes) do
        if attribute[1] == 'data-line-numbers' then return true end
    end
    return false
end

function CodeBlock(block)
    if FORMAT == 'revealjs' then
        css_classes = {}
        pre_tag_params = {}
        code_tag_params = {}

        for _, class in ipairs(block.classes) do
            if is_numberlines_class(class) and
                not is_data_line_number_in_attributes(block.attributes) then
                table.insert(block.attributes, {'data-line-numbers', ''})
            else
                table.insert(css_classes, class)
            end
        end
        if block.identifier ~= '' then
            table.insert(pre_tag_params,
                         string.format('id="%s"', block.identifier))
        end
        if next(css_classes) ~= nil then
            table.insert(code_tag_params, string.format('class="%s"',
                                                        table.concat(
                                                            css_classes, ' ')))
        end
        for _, attribute in ipairs(block.attributes) do
            attribute_string = string.format('%s="%s"', attribute[1],
                                             attribute[2])
            if is_pre_tag_attribute(attribute[1]) then
                table.insert(pre_tag_params, attribute_string)
            else
                table.insert(code_tag_params, attribute_string)
            end
        end
        html = string.format('<pre %s><code %s>%s</code></pre>',
                             table.concat(pre_tag_params, ' '),
                             table.concat(code_tag_params, ' '), block.text)
        return pandoc.RawBlock('html', html)
    end
end
