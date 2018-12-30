local lang = 'english'

local before = pandoc.RawInline(
  'tex', '\\begin{otherlanguage}{' .. lang .. '}')
local after = pandoc.RawInline(
  'tex', '\\end{otherlanguage}')

local meta = {}

return {
  {
    Meta = function (el)
      meta = el
      meta['babel-otherlangs'] = lang
      meta['polyglossia-otherlangs'] = {name = lang}
      return {}
    end,
  }, {
    Code = function(code)
      return {before, code, after}
    end,

    CodeBlock = function(code_block)
      return {
        pandoc.Para({before}),
        code_block,
        pandoc.Para({after})
      }
    end,

    RawBlock = function(raw_block)
      return {
        pandoc.Para({before}),
        raw_block,
        pandoc.Para({after})
      }
    end,
  }, {
    Meta = function (_)
      return meta
    end,
  }
}
