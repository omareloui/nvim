local M = {}

local function jump_diag(next_or_prev)
  local cur = vim.api.nvim_win_get_cursor(0)
  local row, col = cur[1] - 1, cur[2]

  local diags = vim.diagnostic.get(0, {
    severity = { min = vim.diagnostic.severity.INFO },
  })

  local target

  if next_or_prev == "next" then
    for _, d in ipairs(diags) do
      if d.lnum > row or (d.lnum == row and d.col > col) then
        target = d
        break
      end
    end
    if not target then
      target = diags[1]
    end
  else
    for i = #diags, 1, -1 do
      local d = diags[i]
      if d.lnum < row or (d.lnum == row and d.col < col) then
        target = d
        break
      end
    end
    if not target then
      target = diags[#diags]
    end
  end

  if target then
    vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
    vim.diagnostic.open_float(nil, { focusable = false })
  end
end

function M.jump_next()
  jump_diag "next"
end
function M.jump_prev()
  jump_diag "prev"
end

return M
