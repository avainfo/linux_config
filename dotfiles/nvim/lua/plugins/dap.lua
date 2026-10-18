return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
		},
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Debug: start / continue" },
			{ "<leader>dn", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<leader>do", function() require("dap").step_out() end, desc = "Debug: step out" },
			{ "<leader>dp", function() require("dap").pause() end, desc = "Debug: pause" },
			{ "<leader>dq", function() require("dap").terminate() end, desc = "Debug: terminate" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
			{ "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: evaluate expression" },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}

			local function executable()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end

			local configurations = {
				{
					name = "Launch executable (GDB)",
					type = "gdb",
					request = "launch",
					program = executable,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Attach to process (GDB)",
					type = "gdb",
					request = "attach",
					program = executable,
					pid = function()
						return require("dap.utils").pick_process()
					end,
					cwd = "${workspaceFolder}",
				},
			}

			for _, filetype in ipairs({ "c", "cpp", "rust" }) do
				dap.configurations[filetype] = vim.deepcopy(configurations)
			end

			dap.listeners.after.event_initialized["ava_dapui"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["ava_dapui"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["ava_dapui"] = function()
				dapui.close()
			end
		end,
	},
}
