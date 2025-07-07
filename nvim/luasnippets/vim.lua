local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Section comment snippet
  s("sec", {
    t({'" ===', '" === '}),
    i(1, "New Section"),
    t({'"', '" ==='}),
    i(0),
  }),
} 