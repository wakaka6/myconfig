local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Function to generate header guard
local function header_guard()
  local filename = vim.fn.expand("%:t")
  local guard_name = "__" .. filename:gsub("%.", "_"):upper() .. "__"
  return guard_name
end

return {
  -- Header guard snippet
  s("guard", {
    t("#ifndef "),
    f(header_guard),
    t({"", "#define "}),
    f(header_guard),
    t({"", "", ""}),
    i(1),
    t({"", "", "#endif /* "}),
    f(header_guard),
    t(" */"),
  }),
} 