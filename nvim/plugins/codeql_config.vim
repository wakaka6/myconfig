lua << EOF
local status_ok, ql = pcall(require, "codeql")
if not status_ok then
	return
end

local status_ok, win_pic = pcall(require, "window-picker")
if not status_ok then
	return
end

win_pic.setup({
  autoselect_one = true,
  include_current = false,
  filter_rules = {
    bo = {
      filetype = {
        "codeql_panel",
        "codeql_explorer",
        "qf",
        "TelescopePrompt",
        "TelescopeResults",
        "notify",
        "NvimTree",
        "coc-explorer",
        "neo-tree",
      },
      buftype = { 'terminal' },
    },
  },
  current_win_hl_color = '#e35e4f',
  other_win_hl_color = '#44cc41',
})

ql.setup {
  results = {
    max_paths = 10,
    max_path_depth = nil,
  },
  panel = {
    group_by = "sink", -- "source"
    show_filename = true,
    long_filename = false,
    context_lines = 3,
  },
  max_ram = 32000,
  job_timeout = 20000,
  format_on_save = true,
  search_path = {
    os.getenv('QL_HOME') .. "/bin",
    -- os.getenv('QL_HOME') .. "/codeql-repo",
    "./codeql",
  },
  mappings = {
    run_query = { modes = { "n" }, lhs = "<space>qr", desc = "run query" },
    quick_eval = { modes = { "x", "n" }, lhs = "<space>qe", desc = "quick evaluate" },
    quick_eval_predicate = { modes = { "n" }, lhs = "<space>qp", desc = "quick evaluate enclosing predicate" },
  },
}

EOF
