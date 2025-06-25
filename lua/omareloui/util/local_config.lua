local function expand_home(path)
  local home = os.getenv "HOME" or os.getenv "USERPROFILE"
  return path:gsub("^~", home)
end

local M = {
  path = expand_home "~/nvim-local/localconfig.lua",
}

M.config = function()
  local config_path = M.path
  if vim.fn.filereadable(config_path) == 1 then
    local config = dofile(config_path)
    if type(config) == "table" then
      return config
    else
      error "Config file must return a table"
    end
  else
    error("Config file not found: " .. config_path)
  end
end

return M
