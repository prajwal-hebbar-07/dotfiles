return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "mfussenegger/nvim-dap-python",
    "mxsdev/nvim-dap-vscode-js",
  },
  keys = {
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debug: start or continue",
    },
    {
      "<F9>",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: toggle breakpoint",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: step over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: step into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: step out",
    },
    {
      "<leader>bb",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Toggle breakpoint",
    },
    {
      "<leader>bB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "Conditional breakpoint",
    },
    {
      "<leader>bl",
      function()
        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end,
      desc = "Log point",
    },
    {
      "<leader>bc",
      function()
        require("dap").run_to_cursor()
      end,
      desc = "Run to cursor",
    },
    {
      "<leader>br",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Toggle debug REPL",
    },
    {
      "<leader>bu",
      function()
        require("dapui").toggle()
      end,
      desc = "Toggle debug UI",
    },
    {
      "<leader>bx",
      function()
        require("dap").terminate()
      end,
      desc = "Stop debugging",
    },
    {
      "<leader>be",
      function()
        require("dapui").eval()
      end,
      mode = { "n", "x" },
      desc = "Evaluate expression",
    },
    {
      "<leader>bt",
      function()
        require("dap-python").test_method()
      end,
      ft = "python",
      desc = "Debug Python test",
    },
    {
      "<leader>bT",
      function()
        require("dap-python").test_class()
      end,
      ft = "python",
      desc = "Debug Python test class",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
    vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })

    local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    require("dap-python").setup(debugpy_python)

    require("dap-vscode-js").setup({
      debugger_cmd = { "js-debug-adapter" },
      adapters = { "pwa-node", "pwa-chrome" },
    })

    local js_configurations = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Node: Launch current file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Node: Attach to process",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        skipFiles = { "<node_internals>/**" },
      },
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Browser: Launch localhost",
        url = function()
          return vim.fn.input("URL: ", "http://localhost:3000")
        end,
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
      },
    }

    for _, language in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
      dap.configurations[language] = js_configurations
    end
  end,
}
