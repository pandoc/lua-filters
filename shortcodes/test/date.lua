


return {
  ["current-date"] = function(args)
    local format = "%x"
    if #args > 0 then
      format = pandoc.utils.stringify(args[1])
    end
    return pandoc.Str(os.date(format))
  end
}