function addRealCopy (code)
  return { code, pandoc.RawBlock("markdown", code.text) }
end

return {
  { CodeBlock = addRealCopy }
}
