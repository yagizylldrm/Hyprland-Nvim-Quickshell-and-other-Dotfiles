return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			-- 1. Tuş Atamaları (Modern Olay Bazlı Yapı)
			-- Bu kısım, bir LSP bağlandığında otomatik olarak tuşları aktif eder
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf, desc = "Tanıma Git" })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				end,
			})

			-- 2. Mason ile Sunucuları Kur
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"clangd",
					"pyright",
					"html",
					"cssls",
					"lua_ls",
					"jdtls",
					"sqlls",
					"rust_analyzer",
					"gopls",
					"bashls",
					"ts_ls",
				},
			})

			-- 3. Neovim 0.11+ Yöntemiyle Sunucuları Aktif Et
			-- require('lspconfig') kullanmadan doğrudan vim.lsp üzerinden gidiyoruz
			local servers = {
				"clangd",
				"pyright",
				"html",
				"cssls",
				"lua_ls",
				"jdtls",
				"sqlls",
				"rust_analyzer",
				"gopls",
				"bashls",
				"ts_ls",
			}
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			for _, server in ipairs(servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
				})
				vim.lsp.enable(server)
			end

			-- Lua için özel ayar (vim globalini tanıması için hala gerekli)
			vim.lsp.config("lua_ls", {
				settings = { Lua = { diagnostics = { globals = { "vim" } } } },
			})
		end,
	},
}
