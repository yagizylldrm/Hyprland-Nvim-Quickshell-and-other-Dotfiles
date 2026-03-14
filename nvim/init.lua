vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
vim.opt.rtp:prepend("/home/yagizylldrm/.local/share/nvim/site")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 1. Lazy.nvim Kurulumu (Bootstrap)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- 2. Eklentilerin Yüklenmesi
require("lazy").setup({
	spec = {
		-- UI ve Görsellik
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			config = function()
				require("catppuccin").setup({
					integrations = { treesitter = true, rainbow_delimiters = true },
				})
				vim.cmd.colorscheme("catppuccin-mocha")
			end,
		},

		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {
				options = {
					theme = "catppuccin",
					component_seperators = "|",
					section_seperators = { left = "", right = "" },
				},
			},
		},

		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
			lazy = false,
			keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer" } },
		},

		-- IDE Araçları
		{
			"goolord/alpha-nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				local alpha = require("alpha")
				local dashboard = require("alpha.themes.dashboard")
				-- Logo kısmını CENG/RPG ruhuna göre özelleştirebilirsin
				dashboard.section.header.val = {
					"    [ NEOVIM : YAGIZYLLDRM ]    ",
					"  ---------------------------  ",
				}
				dashboard.section.buttons.val = {
					dashboard.button("f", "󰈞  Dosya Bul", ":Telescope find_files <CR>"),
					dashboard.button("r", "󰄉  Son Dosyalar", ":Telescope oldfiles <CR>"),
					dashboard.button("g", "󰊄  Kodda Ara", ":Telescope live_grep <CR>"),
					dashboard.button("c", "  Ayarlar", ":e $MYVIMRC <CR>"),
					dashboard.button("q", "󰅚  Çıkış", ":qa<CR>"),
				}
				alpha.setup(dashboard.config)
			end,
		},

		{
			"iamcco/markdown-preview.nvim",
			cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
			ft = { "markdown" },
			build = function()
				vim.fn["mkdp#util#install"]()
			end,
		},

		-- Todo Comments (Sadece yorumlara odaklanan sürüm)
		{
			"folke/todo-comments.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {
				-- Sadece yorum satırlarındaki keywordleri gösterir
				highlight = {
					comments_only = true,
					max_line_len = 400,
					exclude = { "terminal" }, -- Terminalde tarama yapma
				},
				-- Aranan anahtar kelimeler
				keywords = {
					TODO = { icon = " ", color = "info" },
					FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
					HACK = { icon = " ", color = "warning" },
				},
				search = {
					command = "rg", -- Eğer sisteminde ripgrep varsa çok daha hızlı tarar
					args = {
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
					},
					-- Bu kısım, projenin tamamını mı yoksa sadece açık dosyayı mı tarayacağını belirler
					pattern = [[\b(KEYWORDS):]],
				},
			},
			keys = {
				-- 1. Tüm projeyi Telescope ile aratmak için (En hızlısı)
				{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo'ları Ara (Telescope)" },

				-- 2. Trouble panelini açıp liste olarak görmek için
				{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo Listesi (Trouble)" },

				-- 3. Kodun içinde bir sonraki/önceki not'a hızlıca zıplamak için
				{
					"]t",
					function()
						require("todo-comments").jump_next()
					end,
					desc = "Sonraki Todo",
				},
				{
					"[t",
					function()
						require("todo-comments").jump_prev()
					end,
					desc = "Önceki Todo",
				},
			},
		},

		-- IDE Araçları
		{
			"nvim-telescope/telescope.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			-- cmd ekleyerek manuel :Telescope komutlarını da aktif ediyoruz
			cmd = "Telescope",
			keys = {
				{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Dosya Bul" },
				{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Kod İçinde Ara" },
			},
			-- Eklenti yüklendiğinde varsayılan ayarları yapması için
			config = function()
				require("telescope").setup({})
			end,
		},

		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {},
		},

		-- Neovim 0.11 Uyumlu Treesitter (Modern Yapı)
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			lazy = false,
			priority = 1000,
			config = function()
				local ts = require("nvim-treesitter")
				local languages = { "c", "cpp", "lua", "python", "sql", "bash", "javascript", "html", "css" }

				ts.setup({}) -- Boş setup (0.11 standardı)
				ts.install(languages) -- Dilleri manuel yükleme komutu

				-- Özellikleri her dosya açıldığında manuel aktif eden mekanizma
				vim.api.nvim_create_autocmd("FileType", {
					pattern = languages,
					callback = function()
						-- Neovim'in dahili treesitter renklendirmesini başlatır
						vim.treesitter.start()
						-- Kod katlama (folding) ayarı (isteğe bağlı)
						-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						-- vim.wo.foldmethod = "expr"
					end,
				})
			end,
		},

		-- Rainbow Delimiters (Treesitter'a bağlı bağımsız eklenti)
		{
			"HiPhish/rainbow-delimiters.nvim",
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			lazy = false,
			config = function()
				local rainbow_delimiters = require("rainbow-delimiters")
				vim.g.rainbow_delimiters = {
					strategy = {
						[""] = rainbow_delimiters.strategy["global"],
					},
					query = {
						[""] = "rainbow-delimiters",
					},
				}
			end,
		},

		{
			"folke/trouble.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			opts = {},
			cmd = "Trouble",
			keys = {
				{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Hataları Listele" },
				{ "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Dosya Hataları" },
			},
		},

		{
			"akinsho/toggleterm.nvim",
			version = "*",
			opts = {
				open_mapping = [[<c-\>]], -- Ctrl + \ ile terminali açar/kapatır
				direction = "float", -- Terminali havada (floating) açar
			},
		},

		{
			"mfussenegger/nvim-dap",
			dependencies = {
				"rcarriga/nvim-dap-ui",
				"nvim-neotest/nvim-nio",
			},
			config = function()
				local dap = require("dap")
				local dapui = require("dapui")

				dapui.setup() -- Arayüzü başlat

				-- Debug başladığında ekranı otomatik böl ve arayüzü aç, bitince kapat
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close()
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close()
				end

				-- C++ için codelldb adaptörü ayarı
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						-- Mason ile kuracağımız codelldb'nin tam yolu
						command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
						args = { "--port", "${port}" },
					},
				}

				dap.configurations.cpp = {
					{
						name = "C++ Debug Başlat",
						type = "codelldb",
						request = "launch",
						-- Çalıştırılacak derlenmiş dosyayı otomatik bulur
						program = function()
							return vim.fn.getcwd() .. "/" .. vim.fn.expand("%:r")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}
			end,
			keys = {
				{
					"<leader>db",
					function()
						require("dap").toggle_breakpoint()
					end,
					desc = "Breakpoint (Durak) Koy",
				},
				{
					"<F5>",
					function()
						require("dap").continue()
					end,
					desc = "Debug Başlat / Devam Et",
				},
				{
					"<F10>",
					function()
						require("dap").step_over()
					end,
					desc = "Satırı Atla (Step Over)",
				},
				{
					"<F11>",
					function()
						require("dap").step_into()
					end,
					desc = "İçine Gir (Step Into)",
				},
			},
		},

		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},

		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					cpp = { "clang-format" },
					c = { "clang-format" },
					python = { "black" },
					java = { "google-java-format" },
					html = { "prettier" },
					css = { "prettier" },
					lua = { "stylua" },
					javascript = { "prettier", stop_after_first = true },
					sh = { "shfmt" },
				},
				format_on_save = { timeout_ms = 500, lsp_fallback = true },
			},
		},

		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			opts = {},
		},

		-- 1. Görsel İşaretler (Sol taraftaki renkli Git çizgileri)
		{
			"lewis6991/gitsigns.nvim",
			opts = {
				signs = {
					add = { text = "┃" }, -- Yeni eklenen satırlar (Yeşil)
					change = { text = "┃" }, -- Değiştirilen satırlar (Mavi/Turuncu)
					delete = { text = "_" }, -- Silinen satırlar (Kırmızı)
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				-- O anki satırı kimin, ne zaman yazdığını silik bir yazıyla gösterir (Git Blame)
				current_line_blame = true,
			},
			keys = {
				{
					"<leader>gb",
					"<cmd>Gitsigns toggle_current_line_blame<cr>",
					desc = "Satır Bilgisini (Blame) Aç/Kapat",
				},
			},
		},

		-- 2. Git Arayüzü (Commit, Push, Branch işlemleri için GUI)
		{
			"kdheepak/lazygit.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			keys = {
				{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit Arayüzünü Aç" },
			},
		},

		-- Blink.cmp (Hızlı Kod Tamamlama) Doğru Kurulum
		{
			"saghen/blink.cmp",
			version = "v0.*", -- Uyumsuzluk çıkmaması için sürüm kilitliyoruz
			opts = {
				keymap = { preset = "super-tab" },
				sources = { default = { "lsp", "path", "snippets", "buffer" } },
			},
		},

		{
			"stevearc/aerial.nvim",
			opts = {},
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
			keys = {
				{ "<leader>a", "<cmd>AerialToggle!<cr>", desc = "Kod Haritasını Aç" },
			},
		},

		-- lua/plugins/ altındaki lsp.lua dosyasını yükler
		{ import = "plugins" },
	},
})

-- 3. Temel Ayarlar
vim.cmd.colorscheme("catppuccin-mocha")
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true -- Satırlar arası hızlı zıplama (C++ kodlarında çok işe yarar)

-- Kodu derleyip çalıştıran GARANTİ fonksiyon (Path hatası çözüldü)
local function run_code()
	vim.cmd("write") -- Önce dosyayı kaydet

	-- Dosya yollarını kesin ve güvenli parçalara ayırıyoruz
	local file_dir = vim.fn.expand("%:p:h") -- Dosyanın bulunduğu tam klasör yolu
	local file_name = vim.fn.expand("%:t") -- Sadece dosya adı (ör: main.cpp)
	local file_name_no_ext = vim.fn.expand("%:t:r") -- Uzantısız dosya adı (ör: main)
	local ft = vim.bo.filetype

	local cmd_str = ""

	if ft == "cpp" then
		-- Önce klasöre git (cd), sonra derle, sonra çalıştır
		cmd_str = string.format(
			'bash -c \'cd "%s" && g++ -g "%s" -o "%s" && ./%s\'',
			file_dir,
			file_name,
			file_name_no_ext,
			file_name_no_ext
		)
	elseif ft == "c" then
		cmd_str = string.format(
			'bash -c \'cd "%s" && gcc -g "%s" -o "%s" && ./%s\'',
			file_dir,
			file_name,
			file_name_no_ext,
			file_name_no_ext
		)
	elseif ft == "python" then
		cmd_str = string.format('bash -c \'cd "%s" && python3 "%s"\'', file_dir, file_name)
	elseif ft == "java" then
		cmd_str = string.format('bash -c \'cd "%s" && javac "%s" && java "%s"\'', file_dir, file_name, file_name_no_ext)
	elseif ft == "javascript" then
		cmd_str = string.format('bash -c \'cd "%s" && node "%s"\'', file_dir, file_name)
	elseif ft == "sql" then
		-- SQL kodlarını bulunduğu klasördeki 'test.db' isimli veritabanında çalıştırır
		cmd_str = string.format('bash -c \'cd "%s" && sqlite3 -header -column test.db < "%s"\'', file_dir, file_name)
	elseif ft == "rust" then
		-- Rust kodlarını derler ve çalıştırır (C++'a çok benzer)
		cmd_str = string.format(
			'bash -c \'cd "%s" && rustc "%s" -o "%s" && ./%s\'',
			file_dir,
			file_name,
			file_name_no_ext,
			file_name_no_ext
		)
	elseif ft == "go" then
		-- Go kodlarını anında çalıştırır
		cmd_str = string.format('bash -c \'cd "%s" && go run "%s"\'', file_dir, file_name)
	elseif ft == "sh" then
		-- Linux Bash scriptlerini (.sh) çalıştırır
		cmd_str = string.format('bash -c \'cd "%s" && bash "%s"\'', file_dir, file_name)
	else
		print("Bu dosya tipi desteklenmiyor!")
		return
	end

	-- ToggleTerm'in çekirdek API'sini kullanarak özel terminal oluştur
	local Terminal = require("toggleterm.terminal").Terminal
	local runner = Terminal:new({
		cmd = cmd_str,
		direction = "float",
		close_on_exit = false, -- Çıktıyı okuyabilmen için ekran AÇIK KALIR
		hidden = true,
	})
	runner:toggle()
end

vim.keymap.set("n", "<leader>r", run_code, { desc = "Kodu Derle ve Çalıştır" })
