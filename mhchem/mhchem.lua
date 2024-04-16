-- For better performance we put these functions in local variables:
local P, S, R, Cf, Cc, Ct, V, Cs, Cg, Cb, B, C, Cmt =
  lpeg.P, lpeg.S, lpeg.R, lpeg.Cf, lpeg.Cc, lpeg.Ct, lpeg.V,
  lpeg.Cs, lpeg.Cg, lpeg.Cb, lpeg.B, lpeg.C, lpeg.Cmt

local whitespacechar = S(" \t\r\n")
local number = (R"09"^1 * (P"." * R"09"^1)^-1)
local symbol = C(S"()[],;") + (P"\\" * C(S"{}"))

local function escapeTeX(x)
  return x:gsub("%%","\\%")
          :gsub("\\","\\\\")
          :gsub("([{}])", "\\%1")
end

local arrows = {
  ["->"] = "\\longrightarrow",
  ["<-"] = "\\longleftarrow",
  ["<->"] = "\\longleftrightarrow",
  ["<-->"] = "\\longleftrightarrow", -- for now; we don't have a longer arrow
  ["<=>"] = "\\rightleftharpoons",
  ["<=>>"] = "\\longRightleftharpoons",
  ["<<=>"] = "\\longLeftrightharpoons"
}

local bonds = {
  ["-"] = "{-}",
  ["="] = "{=}",
  ["#"] = "{\\equiv}",
  ["1"] = "{-}",
  ["2"] = "{=}",
  ["3"] = "{\\equiv}",
  ["..."] = "{\\cdot}{\\cdot}{\\cdot}",
  ["...."] = "{\\cdot}{\\cdot}{\\cdot}{\\cdot}",
  ["->"] = "{\\rightarrow}",
  ["<-"] = "{\\leftarrow}",
  ["~"] = "{\\tripledash}",
  ["~-"] = "{\\rlap{\\lower.1em{-}}\\raise.1em{\\tripledash}}",
  ["~--"] = "{\\rlap{\\lower.2em{-}}\\rlap{\\raise.2em{\\tripledash}}-}",
  ["~="] = "{\\rlap{\\lower.2em{-}}\\rlap{\\raise.2em{\\tripledash}}-}",
  ["-~-"] = "{\\rlap{\\lower.2em{-}}\\rlap{\\raise.2em{-}}\\tripledash}"
}

-- math mode renderer
local render =
  { str = function(x)
      if #x > 0 then
        return "\\mathrm{" .. escapeTeX(x) .. "}"
      else
        return ""
      end
    end,
    element = function(x) return "\\mathrm{" .. escapeTeX(x) .. "}" end,
    superscript = function(x) return "^{" .. x .. "}" end,
    subscript = function(x) return "_{" .. x .. "}" end,
    number = function(x) return x end,
    math = function(x) return x end,
    fraction = function(n,d) return "\\frac{" .. n .. "}{" .. d .. "}" end,
    fractionparens = function(n,d) return "(" .. n .. "/" .. d .. ")" end,
    greek = function(x) return "\\mathrm{" .. x .. "}" end,
    arrow = function(arr, above, below)
      local result = arrows[arr]
      if above then
        result = "\\overset{" .. above .. "}{" .. result .. "}"
      end
      if below then
        result = "\\underset{" .. below .. "}{" .. result .. "}"
      end
      return result
    end,
    precipitate = function() return "\\downarrow " end,
    gas = function() return "\\uparrow " end,
    circa = function() return "{\\sim}" end,
    grouped = function(...)
      return "{" .. table.concat(table.pack(...)) .. "}"
    end
  }

Mhchem = P{ "Formula",
  Formula = Ct( V"FormulaPart"^0 ) * P(-1) / table.concat;
  FormulaPart =  V"Molecule"
               + V"ReactionArrow"
               + V"Bond"
               + V"Sup"
               + V"Sub"
               + V"Charge"
               + V"Fraction"
               + V"Number"
               + V"Math"
               + V"Precipitate"
               + V"Gas"
               + V"Letters"
               + V"GreekLetter"
               + V"Circa"
               + V"Text"
               + V"EquationOp"
               + V"Space"
               + V"TeXCommand"
               + V"Times"
               + V"Symbol" ;

  Molecule = V"StoichiometricNumber"^-1 * V"MoleculePart"^1 ;
  MoleculePart = (V"Element" + V"Group") * V"ElementSub"^-1 / render.grouped ;
  Group = Cs(P"(" * V"MoleculePart"^1 * P")") ;
  StoichiometricNumber = (V"Number" + C(R"az") + V"Math" + V"Fraction") *
                          Cc("\\;") * whitespacechar^0 ;
  Element = C(R"AZ" * R"az"^0) / render.element ;
  Charge = B(R"AZ" + R"az" + S")]}") * (S"+-") * #-R"AZ" /
    render.superscript ;
  ElementSub = C(R"09"^1) / render.str / render.subscript ;
  Precipitate = whitespacechar^0 * (P"(v)" + P"v") * whitespacechar^0 /
    render.precipitate ;
  Gas = whitespacechar^0 * (P"(^)" + P"^") * whitespacechar^0 /
    render.gas ;
  Bond = (C(S"#=-") * #R"AZ" / bonds) +
         (P"\\bond{" * Cmt(C((P(1) - P"}")^0),
                       function(subj,pos,capt)
                         local b = bonds[capt]
                         if b then
                           return pos, b
                         else
                           return false
                         end
                       end) * P"}") ;
  Letters = R"az"^1 / render.str ;
  Number = C(number) / render.number;
  NumberOrLetter = V"Number" + V"Letters" ;
  Fraction = (P"(" * V"NumberOrLetter"^1 * P"/" * V"NumberOrLetter"^1 * P")"
              / render.fractionparens) +
             (V"NumberOrLetter" * P"/" * V"NumberOrLetter" / render.fraction);
  Sup = P"^" * (V"InBracesSuper" +
        (C(S"+-"^-1 * R"09"^0 * S"+-"^-1) / render.str)) / render.superscript ;
  Sub = P"_" * (V"InBraces" + (C(S"+-"^-1 * R"09"^0 * S"+-"^-1) / render.str)) /
    render.subscript ;
  TeXCommand = C(P"\\" * (R"AZ" + R"az")^1 * whitespacechar^0 * V"InBraces"^0) ;
  Math = P"$" * Cs((V"MathPart" + V"CEPart")^1) * P"$" / render.math ;
  MathPart = C((P(1) - (P"$" + V"CEPart"))^1) ;
  CEPart = P"\\ce{" * Ct((V"FormulaPart" - P"}")^0) * P"}" / table.concat ;
  GreekLetter = C(P"\\" *
    (( P"alpha" + P"beta" + P"gamma" + P"delta" + P"epsilon" +
      P"zeta" + P"eta" + P"theta" + P"iota" + P"kappa" +
      P"mu" + P"nu" + P"xi" + P"omicron" + P"pi" + P"rho" + P"sigma" +
      P"tau" + P"upsilon" + P"phi" + P"xi" + P"psi" + P"omega"
     ) +
    (( P"Alpha" + P"Beta" + P"Gamma" + P"Delta" + P"Epsilon" +
      P"Zeta" + P"Eta" + P"Theta" + P"Iota" + P"Kappa" +
      P"Mu" + P"Nu" + P"Xi" + P"Omicron" + P"Pi" + P"Rho" + P"Sigma" +
      P"Tau" + P"Upsilon" + P"Phi" + P"Xi" + P"Psi" + P"Omega" )))) *
      whitespacechar^0 / render.greek ;
  EquationOp = whitespacechar^0 *
      C(P"+" + P"-" + P"=" + (P"\\pm")) *
      whitespacechar^0 /
      render.math;
  ReactionArrow =
    whitespacechar^0 *
    C(P"->" +
      P"<-->" +
      P"<->" +
      P"<-" +
      P"<=>>" +
      P"<=>" +
      P"<<=>") *
      (P"[" * Cs((V"FormulaPart" - P"]")^0) * P"]")^-2 *
      whitespacechar^0 / render.arrow ;
  Text = V"InBraces" ;
  Circa = P"\\ca" * whitespacechar^0 / render.circa ;
  Space = C(whitespacechar^1) / "~" ;
  Times =  S".*" / "\\cdot " ;
  Symbol = symbol / render.str;
  InBraces = P"{" * Ct((((V"FormulaPart" - S"{}")^1) + V"InBraces")^0) * P"}" /
    table.concat ;
  InBracesSuper = P"{"
                * Ct(((( ((P"." / "\\bullet ") + V"FormulaPart") - S"{}")^1)
                        + V"InBraces")^0)
                * P"}" / table.concat
  }

function handleCe(s)
  local inner = s:sub(5,-2) -- strip off \ce{ and }
  local result = lpeg.match(Mhchem, inner)
  if not result then
    io.stderr:write("Could not parse mhchem formula " .. inner .. "\n")
    return "\\text{Could not parse}"
  end
  return result
end

function RawInline(el)
  if (el.format == "latex" or el.format == "tex") and
      el.text:match("\\ce{") then
    local result = handleCe(el.text)
    if result then
      return pandoc.Math("InlineMath", handleCe(el.text))
    end
  end
end

function RawBlock(el)
  local il = RawInline(el)
  if il then
    return pandoc.Para(il)
   end
end

function Math(el)
  el.text = string.gsub(el.text, "(\\ce%b{})", handleCe)
  return el
end
