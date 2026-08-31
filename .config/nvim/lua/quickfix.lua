-- The quickfix list as a working set. Mostly built-ins; see :help quickfix.
-- :Cfilter / :Cfilter! narrow an existing list by pattern.
vim.cmd.packadd("cfilter")

vim.keymap.set("n", "<leader>qo", "<Cmd>copen<CR>", { silent = true, desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", "<Cmd>cclose<CR>", { silent = true, desc = "Close quickfix" })
vim.keymap.set("n", "<C-n>", "<Cmd>cnext<CR>", { silent = true, desc = "Next quickfix item" })
vim.keymap.set("n", "<C-p>", "<Cmd>cprev<CR>", { silent = true, desc = "Previous quickfix item" })

-- Append the cursor position and show the list. :cwindow only grabs focus when
-- it opens the window, so restore the window we were in either way.
vim.keymap.set("n", "<leader>qa", function()
	local win = vim.api.nvim_get_current_win()
	vim.cmd([[caddexpr expand("%") .. ":" .. line(".") .. ":" .. getline(".")]])
	vim.cmd("botright cwindow")
	vim.api.nvim_set_current_win(win)
end, { desc = "Add this line to quickfix" })

-- No built-in removes a single entry, so this part needs code.
local function remove_entry()
	local qf = vim.fn.getqflist({ items = 0, idx = 0, title = 0 })
	if #qf.items == 0 then
		return nil
	end

	local idx = qf.idx
	local removed = table.remove(qf.items, idx)
	vim.fn.setqflist({}, "r", { items = qf.items, title = qf.title })
	vim.cmd("botright cwindow") -- shuts itself once the last entry is gone
	return removed, qf.items, idx
end

vim.keymap.set("n", "<leader>qd", function()
	remove_entry()
end, { desc = "Drop entry from list" })

-- Same, but also closes the file. Refuses when that would lose work or strand
-- you in an empty buffer.
vim.keymap.set("n", "<leader>qD", function()
	local removed, rest, idx = remove_entry()
	if not removed then
		return
	end

	local buf = removed.bufnr
	if not buf or buf == 0 or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	if vim.bo[buf].modified then
		vim.notify("unsaved changes; buffer left open", vim.log.levels.WARN)
		return
	end

	local still_used = vim.iter(rest):any(function(item)
		return item.bufnr == buf
	end)
	if still_used then
		return
	end

	-- Step off the buffer before closing it.
	if buf == vim.api.nvim_get_current_buf() then
		if #rest > 0 then
			vim.cmd("cc " .. math.min(idx, #rest))
		else
			pcall(vim.cmd, "bprevious")
		end
	end

	if buf ~= vim.api.nvim_get_current_buf() then
		vim.api.nvim_buf_delete(buf, {})
	end
end, { desc = "Drop entry and close its buffer" })
