local Module = {}

function Module.get_input(prompt)
	return string.format(
		"%s",
		vim.fn.input({
			prompt = prompt,
			cancelreturn = nil,
		})
	)
end

function Module.get_mark(mark)
	local position = vim.api.nvim_buf_get_mark(0, mark)
	if position[1] == 0 then
		return nil
	end
	position[2] = position[2] + 1
	return position
end

function Module.join(lines, joiner)
	local result = ""
	for _, value in ipairs(lines) do
		result = result .. value .. joiner
	end
	return result
end

-- [[
-- Directly calls into get_lines api
-- ]]
function Module.get_lines(start, stop)
	return vim.api.nvim_buf_get_lines(0, start - 1, stop, false)
end

-- [[
-- Directly calls into get_text api
-- ]]
function Module.get_text(first_position, last_position)
	-- I don't understand why this is right, but everything else isn't.
	return vim.api.nvim_buf_get_text(
		0,
		first_position[1] - 1, -- row
		first_position[2] - 1, -- col
		last_position[1] - 1, -- row
		last_position[2], -- col
		{}
	)
end

return Module
