return require('lualine').setup {
    options = {
	icons_enabled = true,
	theme = 'auto',

    },

    sections = {
	lualine_a = {'mode'},
	lualine_b = {'branch', 'diff', 'diagnostics'},
	lualine_c = {'filename'},
	lualine_x = {'encoding', 'fileformat', 'filetype'},
	lualine_y = {'progress'},
	lualine_z = {'location'}
    },

    -- Open buffers along the top. The number shown is the buffer number, so
    -- :b3 jumps straight to it.
    tabline = {
	lualine_a = {{ 'buffers', mode = 2, show_filename_only = true }},
	lualine_z = {{ 'tabs', mode = 0 }},
    }
}
