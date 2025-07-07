local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Error handling snippet
  s("ifer", {
    t({"if err != nil {", "\t"}),
    i(1),
    t({"", "}"}),
    i(0),
  }),

  -- Error comparison snippet
  s("iferr", {
    t("if err == "),
    i(1, "nil"),
    t({" {", "\t"}),
    i(2),
    t({"", "}"}),
    i(0),
  }),
} 