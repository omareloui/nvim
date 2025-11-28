local local_config = require "common.local_config"

local js_based_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

---@param config {args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.input("Run with args: ", table.concat(args, " ")) --[[@as string]]
    return vim.split(vim.fn.expand(new_args) --[[@as string]], " ")
  end
  return config
end

return {
  "mfussenegger/nvim-dap",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },

  -- stylua: ignore
  keys = {
    { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Start/continue" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end, desc = "Debug: Set conditional Breakpoint" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Debug: Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Debug: Go to line (no execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Debug: Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Debug: Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: Step Out" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Debug: Step Over" },
    { "<leader>dp", function() require("dap").pause() end, desc = "Debug: Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Debug: Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
    { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug: Hover" },
    {
      "<leader>da",
      function()
        if vim.fn.filereadable ".vscode/launch.json" then
          local dap_vscode = require "dap.ext.vscode"


          dap_vscode.load_launchjs(nil, {
            ["node"] = js_based_languages,
            ["pwa-node"] = js_based_languages,
            ["chrome"] = js_based_languages,
            ["pwa-chrome"] = js_based_languages,
          })
        end
        require("dap").continue { before = get_args }
      end,
      desc = "Debug: Run with Args",
    },
  },

  config = function()
    -- Styles
    local set_hl = vim.api.nvim_set_hl
    local colors = require "common.ui.palette"
    local icons = require "common.ui.icons"

    set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = colors.red, bg = colors.surface0 })
    set_hl(0, "DapLogPoint", { ctermbg = 0, fg = colors.blue, bg = colors.surface0 })
    set_hl(0, "DapStopped", { ctermbg = 0, fg = colors.green, bg = colors.surface0 })

    for name, sign in pairs(icons.dap) do
      local full_name = "Dap" .. name
      vim.fn.sign_define(full_name, { text = sign, texthl = full_name, linehl = full_name, numhl = full_name })
    end

    -- Setup languages
    local dap = require "dap"

    -- JS configuration --
    if not dap.adapters["pwa-node"] then
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.exepath "js-debug-adapter" .. "/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
    end

    for _, language in ipairs(js_based_languages) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch & Debug Chrome",
            url = function()
              local co = coroutine.running()
              return coroutine.create(function()
                vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:3000" }, function(url)
                  if url == nil or url == "" then
                    return
                  end
                  coroutine.resume(co, url)
                end)
              end)
            end,
            webRoot = "${workspaceFolder}",
            skipFiles = { "<node_internals>/**/*.js" },
            protocol = "inspector",
            sourceMaps = true,
            userDataDir = false,
          },

          {
            name = "---- ↓ launch.json configs ↓ ----",
            type = "",
            request = "launch",
          },
        }
      end
    end
    -- End JS configuration --
  end,

  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      -- stylua: ignore
      keys = {
        { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
        { "<leader>dh", function() require("dapui").eval() end, desc = "Debug: Hover", mode = {"n", "v"} },
      },
      opts = { ensure_installed = { "delve" } },
      config = function()
        local dap = require "dap"
        local dapui = require "dapui"

        dapui.setup {}

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
      end,
    },

    { "theHamsta/nvim-dap-virtual-text", opts = {} },

    {
      "jay-babu/mason-nvim-dap.nvim",
      enabled = local_config.get("lsp.mason.enabled", false),
      dependencies = { "williamboman/mason.nvim" },
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        automatic_installation = false,
        handlers = {},
        ensure_installed = {},
      },
    },

    -- To parse the launch.json if it exists
    { "Joakker/lua-json5", build = "./install.sh" },

    { "leoluz/nvim-dap-go", opts = {} },
  },
}
