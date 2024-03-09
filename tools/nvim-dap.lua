local dap = require("dap")

-- This sets up the python dap adapter with the VIRTUAL_ENV path
-- containing the debubpy which comes with the adapter
require("dap-python").setup(os.getenv("VIRTUAL_ENV"))

dap.configurations.python = {{
  type = 'python';
  request = 'attach';
  name = 'Attach remote';
  connect = function()
    return { host = "localhost", port = 6969}
  end;
  cwd = vim.fn.getcwd(),
  pathMappings = {
      {
          localRoot = function()
              return vim.fn.input("Local code folder > ", vim.fn.getcwd(), "file")
          end,
          remoteRoot = function()
              return vim.fn.input("Container code folder > ", "/home/vunet/workspace/cairo", "file")
          end,
      },
  },
  justMyCode = false,
}}
