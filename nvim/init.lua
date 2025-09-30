vim.g.mapleader = " " -- set mapleader
vim.g.maplocalleader = " " --set maplocalleader
vim.g.have_nerd_font = true --use nerd font
vim.opt.number = true --get line numbers
vim.opt.mouse = "a" --use mouse
vim.opt.showmode = false --no need as it is in status line
vim.opt.clipboard = "unnamedplus" --use system clipboard
vim.opt.breakindent = true --enable break indent
vim.opt.undofile = true --save undo history
vim.opt.ignorecase = true --search is not case sensitive
vim.opt.smartcase = true --search is not case sensitive
vim.opt.signcolumn = "yes" --enable sign column
vim.opt.updatetime = 250 --decrease update time
vim.opt.timeoutlen = 300 --decrease map time

-- setting tabs
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- turn off swapfile
vim.opt.swapfile = false
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 40

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<leader>h", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<leader>l", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<leader>j", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<leader>k", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- lazy nvim
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

-- lazy plugins
local plugins = {
	--colorscheme
	{ "rebelot/kanagawa.nvim", name = "kanagawa", priority = 1000 },
	--fuzzy finder
	{ "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" } },
	-- highlighting and indenting
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	-- tree view
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
		},
	},
	-- bottom line indication
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
	-- lspconfig
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "L3MON4D3/LuaSnip", dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" } },
	{ "hrsh7th/nvim-cmp" },
	{ "stevearc/conform.nvim" },
	{ "lervag/vimtex" },
}
local opts = {}

-- setting lazy
require("lazy").setup(plugins, opts)

-- setting colorscheme
require("kanagawa").setup()
vim.cmd.colorscheme("kanagawa-wave")

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- treesitter
local config = require("nvim-treesitter.configs")
config.setup({
	ensure_installed = {
		"diff",
		"luadoc",
		"markdown_inline",
		"query",
		"c",
		"lua",
		"vim",
		"javascript",
		"html",
		"markdown",
		"python",
		"bash",
	},
	auto_install = true,
	highlight = { enable = true },
	indent = { enable = true },
})

-- neo-tree
require("neo-tree").setup({
	filesystem = {
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
			hide_gitignored = false,
		},
	},
})
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")

-- lualine
require("lualine").setup()

-- mason + mason-lspconfig
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"clangd",
		"ast_grep",
		"jsonls",
		"marksman",
		"pylsp",
		"sqls",
		"lua_ls",
		"texlab",
		"ltex",
	},
})

-- lspconfig
local lspconfig = require("lspconfig")
lspconfig.bashls.setup({})
lspconfig.clangd.setup({})
lspconfig.ast_grep.setup({})
lspconfig.jsonls.setup({})
lspconfig.pylsp.setup({})
lspconfig.sqls.setup({})
lspconfig.marksman.setup({})
lspconfig.lua_ls.setup({})
lspconfig.texlab.setup({})
lspconfig.ltex.setup({})

-- indent-blankline
require("ibl").setup()

-- cmp
local cmp = require("cmp")
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

-- conform
local conform = require("conform")
conform.setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		local lsp_format_opt
		if disable_filetypes[vim.bo[bufnr].filetype] then
			lsp_format_opt = "never"
		else
			lsp_format_opt = "fallback"
		end
		return {
			timeout_ms = 500,
			lsp_format = lsp_format_opt,
		}
	end,
	formatters_by_ft = {
		lua = { "stylua" },
	},
})
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		require("conform").format()
	end,
})
vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

--  VimTeX config
vim.g.vimtex_view_method = "zathura" -- PDF viewer
vim.g.vimtex_compiler_method = "latexmk"
