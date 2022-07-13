vim.cmd([[
" testing lib dirs
set rtp^=./vendor/plenary.nvim/
set rtp^=./vendor/matcher_combinators.lua/

" runtime path of yop itself
set rtp^=../

runtime plugin/plenary.vim
]])

require("plenary.busted")
require("matcher_combinators.luassert")

local yop = require("yop")
local lame_surround = function(lines)
	for index, value in ipairs(lines) do
		lines[index] = "(" .. value .. ")"
	end
	return lines
end
yop.op_map({ "n", "v" }, "(", lame_surround)
