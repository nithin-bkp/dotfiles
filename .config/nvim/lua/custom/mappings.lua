local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {"<cmd> DapToggleBreakpoint <CR>", "Add breakpoint at line"},
    ["<leader>dc"] = {"<cmd> DapContinue <CR>", "Continue/Play debugging"},
    ["<leader>dus"] = {
      function ()
        local widgets = require('dap.ui.widgets');
        local sidebar = widgets.sidebar(widgets.scopes);
        sidebar.open();
      end,
      "Open debugging sidebar"
    },
  }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

M.dap_go = {
  plugin = true,
  n = {
    ["<leader>dgt"] = {
      function()
        require('dap-go').debug_test()
      end,
      "Debug go test"
    },
    ["<leader>dgl"] = {
      function ()
        require('dap-go').debug_last()
      end,
    },
  },
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags",
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags",
    },
  },
}

M.general = {
  n = {
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft<CR>", "window left"},
    ["<C-y>"] = { "<cmd> cprev<CR>", "next item in the quick fix list"},
    ["<C-p>"] = { "<cmd> cnext<CR>", "prev item in the quick fix list"},
    ["<C-j>"] = { "<cmd> TmuxNavigateDown<CR>", "window down"},
    ["<C-k>"] = { "<cmd> TmuxNavigateUp<CR>", "window up"},
    ["<C-l>"] = { "<cmd> TmuxNavigateRight<CR>", "window right"},
    ["<leader><leader>"] = { "<cmd> Telescope buffers<CR>", "Telescope Buffers"},
    ["<leader>e"] = { "<cmd> Oil <CR>", "Open OIl in parent directory"},
  }
}

M.gitsigns = {
  n = {
    ["<leader>hs"] = {
      function()
        require("gitsigns").stage_hunk()
      end,
      "Stage hunk",
    },
    ["<leader>hr"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },
    ["<leader>hS"] = {
      function()
        require("gitsigns").stage_buffer()
      end,
      "Stage buffer",
    },
    ["<leader>hR"] = {
      function()
        require("gitsigns").reset_buffer()
      end,
      "Reset buffer",
    },
  }
}

M.harpoon = {
  n = {
    ["<C-e>"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end
    },
    ["<leader>a"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():add()
      end
    },
    ["<leader>1"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(1)
      end
    },
    ["<leader>2"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(2)
      end
    },
    ["<leader>3"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(3)
      end
    },
    ["<leader>4"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(4)
      end
    },
    ["<leader>5"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(5)
      end
    },
    ["<leader>6"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(6)
      end
    },
    ["<leader>7"] = {
      function ()
        local harpoon = require("harpoon")
        harpoon:list():select(7)
      end
    }
  }
}

M.trouble = {
  n = {
    ["<leader>xx"] = { function() require("trouble").toggle() end },
    ["<leader>xw"] = { function() require("trouble").toggle("workspace_diagnostics") end },
    ["<leader>xd"] = { function() require("trouble").toggle("document_diagnostics") end },
    ["<leader>xq"] = { function() require("trouble").toggle("quickfix") end },
    ["<leader>xl"] = { function() require("trouble").toggle("loclist") end },
    ["gR"]  = {function() require("trouble").toggle("lsp_references") end }
  }
}

return M
