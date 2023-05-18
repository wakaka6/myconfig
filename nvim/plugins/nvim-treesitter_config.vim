lua << EOF

local status_ok, nt = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

nt.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "c", "cpp", "go", "python", "lua", "markdown" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = false,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "all" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = { 'vim' },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = {'markdown'},
  },
}

-- Config curl proxy to download parsers
-- require("nvim-treesitter.install").command_extra_args = {
--     curl = { "--proxy", "<proxy url>" },
-- }

EOF
