vim.cmd("packadd opencode.nvim")

vim.g.opencode_opts = {
	provider = {
		enabled = "tmux",
		terminal = {},
		tmux = {},
	},
}
-- Operator-pending keymaps WITH AUTO-SUBMIT
vim.keymap.set({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ", { submit = true })
end, { expr = true, noremap = true, desc = "Add range to opencode and submit" })

vim.keymap.set("n", "goo", function()
	return require("opencode").operator("@this ", { submit = true }) .. "_"
end, { expr = true, noremap = true, desc = "Add line to opencode and submit" })

-- Sidebar toggle keymap (leader-based)
vim.keymap.set("n", "<leader>oo", function()
	local opencode = require("opencode")
	opencode.stop()
	opencode.toggle()
end, { desc = "Toggle opencode sidebar", noremap = true })

-- Opencode Textarea Prompt Helper
local function opencode_textarea_prompt(opts)
	opts = opts or {}

	-- Get selection or default text
	local code = opts.text or ""
	if opts.visual then
		code = opts.text or ""
	else
		code = opts.text or ""
	end

	-- Format as code block if specified
	if opts.as_code_block ~= false then
		local ft = vim.bo.filetype or "text"
		code = string.format("```%s\n%s\n```", ft, code)
	end

	-- Create scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(code, "\n"))

	-- Floating window dimensions
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.min(120, math.floor(ui.width * 0.7))
	local height = math.min(30, math.floor(ui.height * 0.4))
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((ui.height - height) / 2),
		col = math.floor((ui.width - width) / 2),
		border = "rounded",
		style = "minimal",
	})
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

	-- Keymaps: submit, cancel from within buffer
	vim.keymap.set("n", "<C-CR>", function()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.api.nvim_win_close(win, true)
		local prompt = table.concat(lines, "\n")
		require("opencode").ask(prompt, { submit = true })
	end, { buffer = buf })

	vim.keymap.set("n", "<leader>oa", function()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.api.nvim_win_close(win, true)
		local prompt = table.concat(lines, "\n")
		require("opencode").ask(prompt, { submit = true })
	end, { buffer = buf })

	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	-- Buffer-local command :OpencodeSubmit
	vim.api.nvim_buf_create_user_command(buf, "OpencodeSubmit", function()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.api.nvim_win_close(win, true)
		local prompt = table.concat(lines, "\n")
		require("opencode").ask(prompt, { submit = true })
	end, { desc = "Submit textarea prompt to opencode" })

	-- Remap ':w' and ':write' locally to OpencodeSubmit
	vim.keymap.set("c", "w", function()
		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_feedkeys(":OpencodeSubmit\n", "n", false)
			return ""
		else
			return "w"
		end
	end, { expr = true, buffer = buf })

	vim.keymap.set("c", "write", function()
		if vim.api.nvim_get_current_buf() == buf then
			vim.api.nvim_feedkeys(":OpencodeSubmit\n", "n", false)
			return ""
		else
			return "write"
		end
	end, { expr = true, buffer = buf })

	-- Display usage instructions
	vim.schedule(function()
		vim.api.nvim_echo(
			{ { "Press <C-Enter>, <leader>oa, or :w to submit textarea query", "WarningMsg" } },
			false,
			{}
		)
	end)
end

-- Ask with visually selected text and submit (Textarea-powered)
vim.keymap.set("v", "<leader>oa", function()
	-- Get visual selection positions
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local filepath = vim.fn.expand("%:p")
	if start_pos[2] > 0 and end_pos[2] > 0 then
		local prompt = string.format("@this(%s:%d-%d)", filepath, start_pos[2], end_pos[2])
		opencode_textarea_prompt({ text = prompt, as_code_block = false, visual = true })
	end
end, { desc = "Ask with selected text and submit (Textarea)", noremap = true })

-- Ask prompt in normal mode (Textarea-powered)
vim.keymap.set("n", "<leader>oa", function()
	opencode_textarea_prompt({ as_code_block = true })
end, { desc = "Ask opencode (Textarea)", noremap = true })

-- Add to this table any subprocess PIDs started by plugins, for robust shutdown
_G.opencode_spawned_pids = _G.opencode_spawned_pids or {}

-- Helper: Call this when you start a background Neovim/opencode process
function _G.register_opencode_pid(pid)
  table.insert(_G.opencode_spawned_pids, pid)
end

-- Improved shutdown: Try libuv kill on registered PIDs, fallback to pkill if any remain
vim.api.nvim_create_autocmd({"VimLeavePre", "VimLeave"}, {
  callback = function()
    -- 1. Try plugin's stop first
    local ok, opencode = pcall(require, "opencode")
    if ok and opencode.stop then opencode.stop() end

    -- 2. Use libuv to kill registered PIDs (child Neovims, opencode, etc), escalating to SIGKILL if needed
    local uv = vim.loop
    local any_killed = false
    local killed = {}
    local still_alive = {}
    for _, pid in ipairs(_G.opencode_spawned_pids) do
      -- Try graceful shutdown first
      local ok_term = pcall(function() uv.process_kill(pid, 'sigterm') end)
      if ok_term then any_killed = true end
    end

    -- Wait for processes to exit, but break early if all are gone
    local max_wait = 200  -- total max wait ms
    local interval = 20   -- ms between checks
    local waited = 0
    local function any_alive()
      for _, pid in ipairs(_G.opencode_spawned_pids) do
        local ok = pcall(function() vim.uv.kill(pid, 0) end)
        if ok then return true end
      end
      return false
    end
    while waited < max_wait and any_alive() do
      uv.sleep(interval)
      waited = waited + interval
    end

    -- Check which processes survived, SIGKILL if needed
    for _, pid in ipairs(_G.opencode_spawned_pids) do
      local proc_exists = (function()
        local ok, _, err = pcall(function() return vim.uv.kill(pid, 0) end)
        -- ok=true means process signal was sent, so process exists
        -- ok=false and err=="no such process" or ESRCH means process dead
        return ok
      end)()
      if proc_exists then
        -- SIGKILL if still alive
        local ok_kill = pcall(function() uv.process_kill(pid, 'sigkill') end)
        if ok_kill then
          table.insert(killed, pid)
        else
          table.insert(still_alive, pid)
        end
      end
    end

    -- Safety: Do NOT brute-force kill all opencode/nvim for current user
    -- Only touch registered PIDs (spawned by this instance)
    if #still_alive > 0 then
      local msg = 'Some child opencode/nvim processes could not be killed: ' .. table.concat(still_alive, ', ')
      vim.notify(msg .. '  Manual intervention may be required.', vim.log.levels.WARN)
    elseif any_killed or #killed > 0 then
      vim.notify('All tracked opencode/nvim child processes terminated.', vim.log.levels.INFO)
    else
      vim.notify('No tracked opencode/nvim processes needed termination.', vim.log.levels.INFO)
    end

    -- Diagnostic: Log any remaining suspicious processes (nvim/opencode) to a file
    local logfile = vim.fn.stdpath('cache') .. '/opencode_exit.log'
    vim.fn.system('ps -u $USER | grep -E "nvim|opencode" >> ' .. logfile)

  end,
  desc = "Stop opencode.nvim and kill opencode/nvim child processes on exit (PID-tracked)",
})

-- NOTE: Always track PIDs for safe cleanup! When you spawn a Neovim/opencode process:
-- local jid, pid = vim.fn.jobstart({ ... }, {detach=true}) ...
-- if pid then _G.register_opencode_pid(pid) end
-- Only processes whose PIDs are registered will be killed on exit.
-- Do NOT attempt to kill all opencode/nvim processes system-wide. Plugin authors/users: robustly register only those you start!
-- Telescope UI-select integration
pcall(require, "telescope")
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})
pcall(require("telescope").load_extension, "ui-select")

vim.ui.select = require("telescope").extensions["ui-select"].select
