local function expand_home(path)
  local home = os.getenv "HOME" or os.getenv "USERPROFILE"
  return path:gsub("^~", home)
end

local M = {
  path = expand_home "~/.config/nvim-local/localconfig.lua",
}

M.config = function()
  if M.parsed_config then
    return M.parsed_config
  end

  local config_path = M.path
  if vim.fn.filereadable(config_path) == 1 then
    local config = dofile(config_path)
    if type(config) == "table" then
      M.parsed_config = config
      return config
    else
      error "Config file must return a table"
    end
  else
    error("Config file not found: " .. config_path)
  end
end

---@param key string|nil
---@param default any|nil
M.get = function(key, default)
  local config = M.config()
  if key and type(key) == "string" then
    local keys = vim.split(key, "%.")
    for _, k in ipairs(keys) do
      if config[k] ~= nil then
        config = config[k]
      else
        return default
      end
    end
  end
end

return M
