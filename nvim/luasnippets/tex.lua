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

-- Math context condition (requires vimtex)
local function math()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

-- Comment context condition
local function comment()
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end

-- Environment context condition
local function env(name)
  local result = vim.fn["vimtex#env#is_inside"](name)
  return result[1] ~= 0 and result[2] ~= 0
end

-- Date function
local function get_date()
  return os.date("%Y-%m-%d")
end

-- Box drawing function
local function draw_box(args)
  local text = args[1][1] or ""
  local width = #text + 2
  local top = "┌" .. string.rep("─", width) .. "┐"
  local bottom = "└" .. string.rep("─", width) .. "┘"
  return {top, "│ " .. text .. " │", bottom}
end

return {
  -- Today's date
  s("today", {
    f(get_date),
  }),

  -- Box drawing
  s("box", {
    f(draw_box, {1}),
    t({"", "│ "}),
    i(1),
    t({" │", ""}),
    f(function(args)
      local text = args[1][1] or ""
      local width = #text + 2
      return "└" .. string.rep("─", width) .. "┘"
    end, {1}),
    i(0),
  }),

  -- LaTeX template
  s("temple", {
    t({
      "\\documentclass{ctexbook}",
      "",
      "\\usepackage{amsmath}",
      "\\usepackage{amsfonts}",
      "\\usepackage{amsthm}",
      "\\usepackage{amssymb}",
      "\\usepackage{newtxmath}",
      "\\usepackage{extarrows}",
      "\\usepackage{esint}",
      "\\usepackage{graphicx}",
      "\\usepackage{extarrows}",
      "\\usepackage{dsfont}",
      "",
      "\\usepackage{booktabs,tabularx,multirow,longtable,makecell}",
      "\\usepackage{array}",
      "",
      "% bookmark",
      "\\usepackage[bookmarksnumbered=true, bookmarksopen=true]{hyperref}",
      "\\usepackage[top=2.5cm,bottom=2.5cm,left=2.5cm,right=2.5cm]{geometry}",
      "",
      "\\ctexset {",
      "    chapter = {",
      "        format = \\zihao{3}\\heiti\\centering,",
      "        name = {第,章},",
      "        number = \\arabic{chapter},",
      "        lofskip = {0pt},",
      "        lotskip = {0pt},",
      "        beforeskip = {16pt},",
      "        afterskip = {16pt},",
      "    },",
      "    section = {",
      "        format = \\zihao{-3}\\heiti\\raggedright,",
      "    },",
      "    subsection = {",
      "        format = \\zihao{4}\\heiti\\raggedright,",
      "    },",
      "    subsubsection = {",
      "        format = \\zihao{-4}\\heiti\\raggedright,",
      "    },",
      "}",
      "",
      "\\setcounter{secnumdepth}{3}",
      "\\setcounter{tocdepth}{2}",
      "",
      "\\newcommand{\\Z}{\\mathds{Z}}",
      "\\newcommand{\\R}{\\mathds{R}}",
      "\\newcommand{\\Q}{\\mathds{Q}}",
      "\\newcommand{\\N}{\\mathds{N}}",
      "",
      "\\begin{document}",
      "    \\clearpage",
      "    \\pagenumbering{Roman}",
      "    \\tableofcontents",
      "",
      "    \\clearpage",
      "    \\setcounter{page}{1}",
      "    \\pagenumbering{arabic}",
      "    \\include{"
    }),
    i(1, "chapter1"),
    t({".tex}", "\\end{document}"}),
  }),

  -- Example
  s("e.g.", {
    t("\\noindent\\textbf{[例"),
    i(1),
    t("]}"),
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

  -- Array environment
  s("ar", {
    t("\\begin{array}{"),
    i(1, "c"),
    t({"}","\t"}),
    i(2),
    t({"", "\\end{array}"}),
    i(0),
  }),

  -- Display math
  s(",c", {
    t({"\\[", ""}),
    i(1),
    t({"", ".\\] "}),
    i(0),
  }),

  -- Text in math mode
  s(",t", {
    t("\\text{"),
    i(1),
    t("}"),
  }),

  -- Auto subscript (a1 -> a_1) - only in math mode
  s({trig = "([A-Za-z])(\\d)", regTrig = true, condition = math}, {
    f(function(args, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end),
  }),

  -- Auto subscript for double digits (a12 -> a_{12}) - only in math mode
  s({trig = "([A-Za-z])_(\\d\\d)", regTrig = true, condition = math}, {
    f(function(args, snip)
      return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    end),
  }),

  -- Column vector
  s("cvec", {
    t("\\begin{pmatrix} "),
    i(1, "x"),
    t("_"),
    i(2, "1"),
    t("\\\\\\\\ \\vdots\\\\\\\\ "),
    rep(1),
    t("_"),
    rep(2),
    t(" \\end{pmatrix}"),
  }),

  -- Fraction (math mode)
  s({trig = "//", condition = math}, {
    t("\\frac{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
    i(0),
  }),

  -- Complex fraction (math mode)
  s({trig = "((\\d+)|(\\d*)(\\\\)?([A-Za-z]+)((\\^|_)(\\{\\d+\\}|\\d))*)/", regTrig = true, condition = math}, {
    t("\\frac{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Parentheses fraction (math mode)
  s({trig = "^.*\\)/", regTrig = true, condition = math}, {
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

  -- Simple fraction
  s({trig = "/", priority = 5}, {
    t("\\frac{"),
    i(1),
    t("}{"),
    i(2),
    t("}"),
    i(0),
  }),

  -- Hat (math mode)
  s({trig = "hat", condition = math, priority = 10}, {
    t("\\hat{"),
    i(1),
    t("}"),
    i(0),
  }),

  -- Letter hat (math mode)
  s({trig = "([a-zA-Z])hat", regTrig = true, condition = math, priority = 100}, {
    t("\\hat{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),

  -- Vector postfix (math mode)
  s({trig = "(\\w+)vec", regTrig = true, condition = math}, {
    t("\\vec{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),

  -- Bar postfix (math mode)
  s({trig = "(\\w+)bar", regTrig = true, condition = math}, {
    t("\\bar{"),
    f(function(args, snip)
      return snip.captures[1]
    end),
    t("}"),
  }),

  -- Integral
  s({trig = "int", priority = 5}, {
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

  -- Limit
  s("lim", {
    t("\\lim\\limits_{"),
    i(1, "n"),
    t(" \\to "),
    i(2, "\\infty"),
    t("} "),
  }),

  -- Exists (math mode)
  s({trig = "EE", condition = math}, {
    t("\\exists "),
  }),

  -- For all (math mode)
  s({trig = "AA", condition = math}, {
    t("\\forall "),
  }),

  -- Cross product (math mode)
  s({trig = "xx", condition = math}, {
    t("\\times "),
  }),

  -- Similarity
  s("~~", {
    t("\\sim "),
  }),

  -- Number sets
  s("NN", {
    t("\\N"),
  }),
  s("RR", {
    t("\\R"),
  }),
  s("QQ", {
    t("\\Q"),
  }),
  s("ZZ", {
    t("\\Z"),
  }),

  -- Left-right delimiters
  s("lr", {
    t("\\left( "),
    i(1),
    t(" \\right) "),
    i(0),
  }),
  s("lr(", {
    t("\\left( "),
    i(1),
    t(" \\right) "),
    i(0),
  }),
  s("lr|", {
    t("\\left| "),
    i(1),
    t(" \\right| "),
    i(0),
  }),
  s("lr{", {
    t("\\left\\{ "),
    i(1),
    t(" \\right\\} "),
    i(0),
  }),
  s("lr[", {
    t("\\left[ "),
    i(1),
    t(" \\right] "),
    i(0),
  }),
  s("lr<", {
    t("\\left<"),
    i(1),
    t(" \\right>"),
    i(0),
  }),

  -- Sympy integration
  s("sympy", {
    t("sympy "),
    i(1),
    t(" sympy"),
    i(0),
  }),

  -- Sympy evaluation (complex regex)
  s({trig = "sympy(.*)sympy", regTrig = true, priority = 10000}, {
    f(function(args, snip)
      -- This would require actual sympy integration
      -- For now, just return the captured content
      local content = snip.captures[1]
      content = content:gsub("\\", "")
      content = content:gsub("%^", "**")
      content = content:gsub("{", "(")
      content = content:gsub("}", ")")
      return "% Sympy result for: " .. content
    end),
  }),
} 