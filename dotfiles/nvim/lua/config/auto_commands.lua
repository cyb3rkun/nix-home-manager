local autocmd = vim.api.nvim_create_autocmd

vim.cmd("highlight YankHighlight guifg=#000000 guibg=#00FFFF")
vim.cmd(
	"highlight YankHighlightClipboard guifg=#1d202f guibg=#ff9e64"
)

autocmd("TextYankPost", {
	desc = "Highlight when yanking text",

	group = vim.api.nvim_create_augroup("Cyb3rVim-highlight-yank", {
		clear = true,
	}),

	callback = function()
		local reg = vim.v.register

		local hgroup = "YankHighlight"
		if reg == "+" or reg == "*" then
			hgroup = "YankHighlightClipboard"
		end
		vim.highlight.on_yank({
			higroup = hgroup,
		})
	end,
})
autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup(
		"Cyb3rVim-custom-highlights",
		{ clear = true }
	),
	callback = function()
		vim.cmd("highlight YankHighlight guifg=#000000 guibg=#00FFFF")
		vim.cmd(
			"highlight YankHighlightClipboard guifg=#1d202f guibg=#ff9e64"
		)
	end,
})

-- NOTE: remove line numbers for neotree only
autocmd("BufEnter", {
	callback = function()
		if vim.bo.filetype == "neo-tree" then
			vim.cmd("setlocal statuscolumn=")
		end
	end,
})

local server_started
autocmd({ "VimEnter", "DirChanged" }, {
	callback = function()
		local server_address = "/tmp/godothost"

		local current_working_directory = vim.fn.getcwd() .. "/"
		local root_file_pattern = {
			"project.godot",
			".gdproject",
		}

		for _, root_file_path in ipairs(root_file_pattern) do
			local file_path = current_working_directory
				.. root_file_path

			if
				vim.fn.filereadable(file_path) == 1
				and not server_started
			then
				print(
					"Found Godot Project root pattern... Starting LSP"
				)
				vim.fn.serverstart(server_address)
				server_started = true
				P(vim.fn.serverlist())
				return
			else
				vim.fn.serverstop(server_address)
			end
		end
	end,
})

autocmd({ "BufWinLeave" }, {
	pattern = "?*",
	callback = function() vim.cmd("mkview") end,
})
autocmd({ "BufWinEnter" }, {
	pattern = "?*",
	callback = function() vim.cmd("silent! loadview") end,
})

autocmd({ "BufEnter", "BufWinEnter", "BufWinLeave" }, {
	callback = function()
		if vim.bo.filetype == "undotree" then
			print("resize window")
			local max_width = 30
			local win_width = vim.fn.winwidth(0)
			vim.cmd(
				"vertical resize " .. math.min(max_width, win_width)
			)
		end
	end,
})
autocmd({ "BufEnter", "FileType" }, {
	pattern = "html",
	callback = function()
		vim.keymap.set("n", "<LocalLeader>x", function()
			print("opening in browser")
			vim.ui.open(vim.fn.expand("%"))
		end, {
			desc = " Open File In Browser",
		})
	end,
})
