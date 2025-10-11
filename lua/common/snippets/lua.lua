---@diagnostic disable: undefined-global

local function package_to_var(args)
  local name_spaces = vim.split(args[1][1], ".", { plain = true, trimempty = true })
  local last_name = name_spaces[#name_spaces] or ""
  return last_name:gsub("-", "_")
end


local cs, snippets, autosnippets = require "common.snippets.utils" ("*.lua", "LuaSnippets")

cs(
  "req",
  fmt([[local {} = require "{}"]], {
    f(package_to_var, { 1 }),
    i(1, "package_name"),
  })
)

cs(
  "pcall",
  fmt(
    [[local is_{}_ok, {} = pcall(require, "{}")

-- stylua: ignore
if not is_{}_ok then return end]],
    {
      f(package_to_var, { 1 }),
      f(package_to_var, { 1 }),
      i(1, "package_name"),
      f(package_to_var, { 1 }),
    }
  )
)

return snippets, autosnippets
