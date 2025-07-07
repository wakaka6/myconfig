local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")

-- Function to generate table separators
local function generate_table_separator(args)
  local line = args[1][1]
  local count = 0
  local escaped = false
  
  for i = 1, #line do
    local char = line:sub(i, i)
    if char == "|" and not escaped then
      count = count + 1
    end
    escaped = (char == "\\")
  end
  
  if count > 0 then
    local result = "|"
    for _ = 1, count do
      result = result .. " <,.> |"
    end
    return result
  end
  return ""
end

return {
  -- Table auto expand (regex-like trigger)
  s({trig = "^%s*|(.+)|$", regTrig = true}, {
    f(function(args, snip)
      return snip.trigger .. "\n"
    end),
    i(0),
    f(generate_table_separator, {-1}),
  }),

  -- Inline math
  s(",m", {
    t("$"),
    i(1),
    t("$"),
    f(function(args, snip)
      local next_char = snip.env.POSTFIX or ""
      if next_char:match("^[,.?%- ]") then
        return ""
      else
        return " "
      end
    end),
    i(2),
  }),

  -- Block math equation
  s("eq", {
    t({"$$", ""}),
    i(1),
    t({"", "$$"}),
    i(0),
  }),

  -- Array environment
  s("ar", {
    t("\\begin{array}{"),
    i(1, "c"),
    t({"}","\t"}),
    i(2),
    t({"", "\\end{array}"}),
    i(0),
  }),

  -- Align environment
  s("al", {
    t({"\\begin{aligned}", "\t"}),
    i(1),
    t({"", "\\end{aligned}"}),
    i(0),
  }),

  -- Cases environment
  s("cases", {
    t({"\\begin{cases}", "\t"}),
    i(1),
    t({"", "\\end{cases}"}),
    i(0),
  }),

  -- Text in math mode
  s("text", {
    t("\\text{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Fraction
  s("frac", {
    t("\\frac{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
    i(0),
  }),

  -- Partial derivative
  s("part", {
    t("\\frac{\\partial "),
    i(1, "V"),
    t("}{\\partial "),
    i(2, "x"),
    t("} "),
    i(0),
  }),

  -- Square root
  s("srt", {
    t("\\sqrt{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Sum
  s("sum", {
    t("\\sum_{n="),
    i(1, "1"),
    t("}^{"),
    i(2, "\\infty"),
    t("} "),
    i(3, "a_n z^n"),
  }),

  -- Product
  s("prod", {
    t("\\prod_{"),
    i(1, "n="),
    i(2, "1"),
    t("}^{"),
    i(3, "\\infty"),
    t("} "),
    i(4),
    t(" "),
    i(0),
  }),

  -- Limit
  s("lim", {
    t("\\lim\\limits_{"),
    i(1, "n"),
    t(" \\to "),
    i(2, "\\infty"),
    t("} "),
  }),

  -- Implies
  s("=>", {
    t("\\implies"),
  }),

  -- Implied by
  s("=<", {
    t("\\impliedby"),
  }),

  -- If and only if
  s("iff", {
    t("\\iff"),
  }),

  -- Equals with alignment
  s("==", {
    t("&= "),
    i(1),
    t(" \\\\"),
  }),

  -- Not equal
  s("!=", {
    t("\\neq "),
  }),

  -- Less than or equal
  s("<=", {
    t("\\le "),
  }),

  -- Greater than or equal
  s(">=", {
    t("\\ge "),
  }),

  -- Equivalence
  s("eqv", {
    t("\\equiv "),
  }),

  -- Derivative
  s("dv", {
    t("\\frac{d "),
    i(1),
    t("}{d "),
    i(2),
    t("} "),
    i(0),
  }),

  -- Summation
  s("summ", {
    t("\\sum_{"),
    i(1),
    t("} "),
    i(0),
  }),

  -- Dot derivative
  s("dot", {
    t("\\dot{"),
    i(1),
    t("} "),
    i(0),
  }),

  -- Double dot derivative
  s("ddot", {
    t("\\ddot{"),
    i(1),
    t("} "),
    i(0),
  }),

  -- Vector
  s("vec", {
    t("\\vec{"),
    i(1),
    t("} "),
    i(0),
  }),

  -- Cross product
  s("\\x", {
    t("\\times "),
    i(0),
  }),

  -- Dot product
  s(".", {
    t("\\cdot "),
    i(0),
  }),

  -- Integral
  s("int", {
    t("\\int_{"),
    i(1),
    t("}^{"),
    i(2),
    t("} "),
    i(3),
    t(" \\: d"),
    i(4),
    t(" "),
    i(0),
  }),

  -- Right arrow
  s("ra", {
    t("\\rightarrow "),
    i(0),
  }),

  -- Long right arrow
  s("lra", {
    t("\\longrightarrow "),
    i(0),
  }),

  -- Matrix
  s("mat", {
    t("\\begin{"),
    c(1, {
      t("pmatrix"),
      t("bmatrix"),
      t("vmatrix"),
      t("Vmatrix"),
      t("Bmatrix"),
      t("smallmatrix"),
    }),
    t({"}", "\t"}),
    i(2),
    t({"", "\\end{"}),
    rep(1),
    t("}"),
  }),

  -- Auto subscript (regex trigger for a1 -> a_1)
  s({trig = "([A-Za-z])(\\d)", regTrig = true}, {
    f(function(args, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end),
  }),

  -- Auto subscript for double digits (a12 -> a_{12})
  s({trig = "([A-Za-z])_(\\d\\d)", regTrig = true}, {
    f(function(args, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
  }),

  -- Fraction shortcuts
  s("//", {
    t("\\frac{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
    i(0),
  }),

  -- Complex fraction (regex trigger)
  s({trig = "((\\d+)|(\\d*)(\\\\)?([A-Za-z]+)((\\^|_)(\\{\\d+\\}|\\d))*)/", regTrig = true}, {
    t("\\frac{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Parentheses fraction
  s({trig = "^.*\\)/", regTrig = true}, {
    f(function(args, snip)
      local stripped = snip.trigger:sub(1, -2)
      local depth = 0
      local i = #stripped
      while i >= 1 do
        local char = stripped:sub(i, i)
        if char == ")" then
          depth = depth + 1
        elseif char == "(" then
          depth = depth - 1
        end
        if depth == 0 then
          break
        end
        i = i - 1
      end
      if i == 0 then
        return "\\frac{" .. stripped:sub(2, -2) .. "}"
      else
        return stripped:sub(1, i-1) .. "\\frac{" .. stripped:sub(i+1, -2) .. "}"
      end
    end),
    t("{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Hat
  s("hat", {
    t("\\hat{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Letter hat (regex trigger for ihat -> \hat{i})
  s({trig = "([a-zA-Z])hat", regTrig = true}, {
    t("\\hat{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),

  -- Vector postfix (regex trigger for v_1vec -> \vec{v_1})
  s({trig = "(\\w+)vec", regTrig = true}, {
    t("\\vec{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),

  -- Bar postfix (regex trigger for v_1bar -> \bar{v_1})
  s({trig = "(\\w+)bar", regTrig = true}, {
    t("\\bar{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),
} 