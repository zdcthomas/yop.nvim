local psyop = require("psy_op")
local cursor = vim.fn.cursor

local function set_lines(lines)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local function assert_lines(lines)
	assert.are.same(lines, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end

local function type(input)
  input = vim.api.nvim_replace_termcodes(input, true, false, true)
	vim.api.nvim_feedkeys(input, "x", true)
end

local function operate(operator, textobj)
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(operator .. esc, "n", false)
	vim.api.nvim_feedkeys("g@" .. textobj, "n", false)
end

describe("operators", function()

  before_each(function ()
    cursor(1,1)
    set_lines({})
  end)

	it("operates on charwise motions", function()
		set_lines({ "test word" })
		cursor(1, 7)
		require("psy_op").create_operator(function(lines)
			for index, value in ipairs(lines) do
				lines[index] = "(" .. value .. ")"
			end
			return lines
		end)()

		type("iw")
		assert_lines({ "test (word)" })
	end)

	it("operates on charwise visual selections", function()
		set_lines({ "first line", "second line" })

    type("viw")

		require("psy_op").create_operator(function(lines)
			for index, value in ipairs(lines) do
				lines[index] = "(" .. value .. ")"
			end
			return lines
		end)()

		type("<ESC>")
		type("g@")

		-- type("iw")
		assert_lines({ "(first) line", "second line" })
	end)

	it("operates on linewise visual selections", function()
		set_lines({ "first line", "second line" })

    type("V")

		require("psy_op").create_operator(function(lines)
			for index, value in ipairs(lines) do
				lines[index] = "(" .. value .. ")"
			end
			return lines
		end)()

		type("<ESC>")
		type("g@")

		-- type("iw")
		assert_lines({ "(first line)", "second line" })
	end)

	it("operates on blockwise visual selections", function()
		set_lines({ "first line", "second line" , "third line"})
		cursor(1, 3)

    type("<c-v>jj")

		require("psy_op").create_operator(function(lines)
			for index, value in ipairs(lines) do
				lines[index] = "(" .. value .. ")"
			end
			return lines
		end)()

		type("<ESC>")
		type("g@")

		assert_lines({ "fi(r)st line", "se(c)ond line" , "th(i)rd line"})
	end)

end)