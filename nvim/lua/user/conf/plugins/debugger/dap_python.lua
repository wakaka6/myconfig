-- ===
-- === Debug python
-- ===

-- config adapter
local dap = require('dap')

dap.adapters.python = {
  type = 'executable';
  -- command = 'path/to/virtualenvs/debugpy/bin/python';
  command = '/usr/bin/python';
  args = { '-m', 'debugpy.adapter' };
}

-- config debuger
dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    type = 'python'; -- the type here established the link to the adapter definition: `dap.adapters.python`
    request = 'launch';
    name = "Launch file";

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

    program = "${file}"; -- This configuration will launch the current file if used.
    pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      local cwd = vim.fn.getcwd()
      local venv_command = string.format("%s/bin/python", os.getenv("VIRTUAL_ENV"))
      if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      elseif vim.fn.executable(venv_command) == 1 then
        return venv_command
      else
        return '/usr/bin/python'
      end

    end
  }
}
