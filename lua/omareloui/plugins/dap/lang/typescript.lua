local js_based_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" }

return {
  js_based_languages = js_based_languages,

  setup = function(dap)
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
  end,
}
