---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'mountain',
  tabufline = {
    enabled= false
  }
}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
