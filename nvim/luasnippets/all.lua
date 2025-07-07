local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Snippet for writing snippets
  s("snip", {
    t('s("'),
    i(1, "trigger"),
    t('", {'),
    t({"", "\t"}),
    i(2, "-- snippet content"),
    t({"", "}),"}),
    i(0),
  }),
} 