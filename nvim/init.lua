-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy.nvim
require("lazy").setup({
	spec = {

        {
            "rebelot/kanagawa.nvim",
       },

        {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { {"nvim-lua/plenary.nvim"} }
        },

		{	
			'nvim-telescope/telescope.nvim', tag = '0.1.8',
			dependencies = {
				'nvim-lua/plenary.nvim',
				"mfussenegger/nvim-dap",
				"nvim-telescope/telescope-dap.nvim",
				"nvim-neotest/nvim-nio",
			},
			config = function()
			require('telescope').setup{
				defaults = {
					-- Default configuration for telescope goes here:
					-- config_key = value,
					mappings = {
					i = {
						-- map actions.which_key to <C-h> (default: <C-/>)
							-- actions.which_key shows the mappings for your picker,
							-- e.g. git_{create, delete, ...}_branch for the git_branches picker
							["<C-h>"] = "which_key"
						}
					}
				},
				pickers = {
					-- Default configuration for builtin pickers goes here:
					-- picker_name = {
						--   picker_config_key = value,
						--   ...
						-- }
						-- Now the picker_config_key will be applied every time you call this
						-- builtin picker
					},
					extensions = {

						require('telescope').load_extension('dap')
						-- Your extension configuration goes here:
						-- extension_name = {
							--   extension_config_key = value,
							-- }
							-- please take a look at the readme of the extension you want to configure
						}
					}

					local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
				vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
				vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
				vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
				vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
				vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
				vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
				vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
				vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
				vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

				-- Slightly advanced example of overriding default behavior and theme
				vim.keymap.set("n", "<leader>/", function()
					-- You can pass additional configuration to Telescope to change the theme, layout, etc.
					builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end, { desc = "[/] Fuzzily search in current buffer" })

				-- It's also possible to pass additional configuration options.
				--  See `:help telescope.builtin.live_grep()` for information about particular keys
				vim.keymap.set("n", "<leader>s/", function()
					builtin.live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end, { desc = "[S]earch [/] in Open Files" })

				-- Shortcut for searching your Neovim configuration files
				vim.keymap.set("n", "<leader>sn", function()
					builtin.find_files({ cwd = vim.fn.stdpath("config") })
				end, { desc = "[S]earch [N]eovim files" })
			end,
		},


				{
					"nvim-treesitter/nvim-treesitter",
					opts = {
						ensure_installed = {
							"bash",
							"html",
							"javascript",
							"json",
							"lua",
							"markdown",
							"markdown_inline",
							"query",
							"regex",
							"tsx",
							"typescript",
							"vim",
							"yaml",
						},
					},
				},

				{
					"neovim/nvim-lspconfig",
				},


				{
					"williamboman/mason.nvim",
					opts = {
						ensure_installed = {
							"stylua",
							"shellcheck",
							"shfmt",
							"flake8",
						},
					},
				},

				{"williamboman/mason-lspconfig.nvim",
				config = function()
					require("mason").setup({
						ui = {
							icons = {
								package_installed = "✓",
								package_pending = "➜",
								package_uninstalled = "✗"
							}
						}
					})
					require("mason-lspconfig").setup {
						ensure_installed = { "lua_ls", "rust_analyzer", "pyright" },
					}   
				end
			},

			{
				"hrsh7th/nvim-cmp",
				event = "InsertEnter",
				dependencies = {

					{
						"L3MON4D3/LuaSnip",
						-- follow latest release.
						version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
						-- install jsregexp (optional!).
						build = "make install_jsregexp"
					},

					"saadparwaiz1/cmp_luasnip",
					"hrsh7th/cmp-nvim-lsp",
					"hrsh7th/cmp-path",
					"hrsh7th/cmp-nvim-lsp-signature-help",
				},

				config = function()
					local cmp = require("cmp")
					local luasnip = require("luasnip")
					luasnip.config.setup({})

					cmp.setup({
						snippet = {
							expand = function(args)
								luasnip.lsp_expand(args.body)
							end,
						},
						completion = { completeopt = "menu,menuone,noinsert" },

						mapping = cmp.mapping.preset.insert({
							-- Select the [n]ext item
							["<C-n>"] = cmp.mapping.select_next_item(),
							-- Select the [p]revious item
							["<C-p>"] = cmp.mapping.select_prev_item(),

							-- Scroll the documentation window [b]ack / [f]orward
							["<C-b>"] = cmp.mapping.scroll_docs(-4),
							["<C-f>"] = cmp.mapping.scroll_docs(4),

							-- Accept ([y]es) the completion.
							--  This will auto-import if your LSP supports it.
							--  This will expand snippets if the LSP sent a snippet.
							["<C-y>"] = cmp.mapping.confirm({ select = true }),

							-- If you prefer more traditional completion keymaps,
							-- you can uncomment the following lines
							--['<CR>'] = cmp.mapping.confirm { select = true },
							--['<Tab>'] = cmp.mapping.select_next_item(),
							--['<S-Tab>'] = cmp.mapping.select_prev_item(),

							-- Manually trigger a completion from nvim-cmp.
							--  Generally you don't need this, because nvim-cmp will display
							--  completions whenever it has completion options available.
							["<C-Space>"] = cmp.mapping.complete({}),

							-- Think of <c-l> as moving to the right of your snippet expansion.
							--  So if you have a snippet that's like:
							--  function $name($args)
							--    $body
							--  end
							--
							-- <c-l> will move you to the right of each of the expansion locations.
							-- <c-h> is similar, except moving you backwards.
							["<C-l>"] = cmp.mapping(function()
								if luasnip.expand_or_locally_jumpable() then
									luasnip.expand_or_jump()
								end
							end, { "i", "s" }),
							["<C-h>"] = cmp.mapping(function()
								if luasnip.locally_jumpable(-1) then
									luasnip.jump(-1)
								end
							end, { "i", "s" }),

							-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
							--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
						}),
						sources = {
							{ name = "nvim_lsp" },
							{ name = "luasnip" },
							{ name = "path" },
							{ name = "nvim_lsp_signature_help" },
						},
					})
				end,
			},



		},
		-- Configure any other settings here. See the documentation for more details.
		-- colorscheme that will be used when installing plugins.
		install = { colorscheme = { "habamax" } },
		-- automatically check for plugin updates
		checker = { enabled = true },
	})

	local core = require('cmp.core')
	local source = require('cmp.source')
	local config = require('cmp.config')
	local feedkeys = require('cmp.utils.feedkeys')
	local autocmd = require('cmp.utils.autocmd')
	local keymap = require('cmp.utils.keymap')
	local misc = require('cmp.utils.misc')
	local async = require('cmp.utils.async')

	local cmp = {}

	vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

local harpoon = require('harpoon')
harpoon:setup({})

-- basic telescope configuration
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window" })

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)

vim.cmd.colorscheme("kanagawa-dragon")
