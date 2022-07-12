local utils = require("psy_op.utils")

local Module = {
	transformations = {},
	debug_level = 0,
	__debug_level = 0,
	__opfunc = function(type)
		print(type)
	end,
}

local function debug(message, level)
	level = level or 0
	if level < Module.__debug_level then
		vim.pretty_print(message)
	end
end

local function get_line_from_type(callback_type, first_position, last_position)
	-- different types of operator funcs need different ways of getting lines
	if callback_type == "line" then
		return utils.get_lines(first_position[1], last_position[1])
	elseif callback_type == "char" then
		return utils.get_text(first_position, last_position)
	elseif callback_type == "block" then
		local old_reg = vim.fn.getreg("a")
		vim.cmd([[norm! gv"ay ]])
		local lines = vim.split(vim.fn.getreg([[a]]), "\n")
		vim.fn.setreg("a", old_reg)
		return lines
	else
		debug("callback_type " .. callback_type .. " is un-supported")
		return
	end
end

local set_lines = function(start, stop, lines)
	vim.api.nvim_buf_set_lines(0, start - 1, stop, false, lines)
end

local function get_positions()
	-- TODO: This should be driven by the type
	-- vim.o.selection = "inclusive"
	-- it seems like these marks work properly in visual mode as well, but I'm not sure yet
	return utils.get_mark("["), utils.get_mark("]")
end

local function create_opfunc(funk)
	debug("4: opfunc being created and set")
	return function(callback_type)
		debug("5: opfunc called")
		-- vim.o.selection = "inclusive"
		local first_position, last_position = get_positions()

		debug("6: positions retrieved")
		local lines = get_line_from_type(callback_type, first_position, last_position)
		if not lines then
			return
		end

		-- Use the callback defined by the user to transform the lines
		local maybe_lines = funk(lines, {
			position = {
				first = first_position,
				last = last_position,
			},
			type = callback_type,
		})

		debug("8: lines have been transformed ")

		if not maybe_lines then
			return
		else
			lines = maybe_lines
		end

		if callback_type == "line" then
			set_lines(first_position[1], last_position[1], lines)
		elseif callback_type == "char" then
			-- Replace the lines in the correct buffer
			vim.api.nvim_buf_set_text(
				0,
				first_position[1] - 1,
				first_position[2] - 1,
				last_position[1] - 1,
				last_position[2],
				lines
			)
		elseif callback_type == "block" then
			local old_a_reg = vim.fn.getreg("a")
			local reg_ready = utils.join(lines, "\n")
			-- This is gross and I would love for there to be a better way
			vim.fn.setreg("a", reg_ready, "b")
			vim.cmd([[norm! gv"ap]])
			vim.fn.setreg("a", old_a_reg, "b")
		end

		debug("9: lines have been sent")
	end
end

function Module.linewise(callback_funk)
	return function()
		vim.api.nvim_feedkeys("^", "n", false)
		callback_funk()
		vim.api.nvim_feedkeys("g_", "n", false)
	end
end

function Module.create_operator(funk)
	debug("2: create_operator")
	return function()
		debug("3: actual mapping called")
		-- local old_op_func = vim.go.operatorfunc
		Module.__opfunc = create_opfunc(funk)
		vim.go.operatorfunc = "v:lua.require'psy_op'.__opfunc"

		-- Other plugins have this as a string being returned, and then the mapping
		-- has to be an expression. I don't understand why.
		-- using feedkeys works in practice, but not in test
		vim.api.nvim_feedkeys("g@", "n", false)
	end
end

-- I don't need this but for now I'm keeping it
function Module.op_map(mode, mapping, funk, opts)
	debug("1: op_map called")
	opts = opts or {}
	vim.validate({
		mode = { mode, { "string", "table" } },
		mapping = { mapping, "string" },
		funk = { funk, "function" },
		opts = { opts, "table" },
	})

	-- opts = vim.tbl_deep_extend("force", opts, { expr = true })

	vim.keymap.set(mode, mapping, Module.create_operator(funk), opts)
end

return Module
