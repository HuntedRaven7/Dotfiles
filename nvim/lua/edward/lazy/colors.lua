function ColorMyPencils(color)
	color = color or "vscode"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end


return{'Mofiqul/vscode.nvim',
    config = function()
        require('vscode').setup({
        disable_background = true,
                styles = {
                    italic = false,
        },
            })
        ColorMyPencils();
    end

  }


