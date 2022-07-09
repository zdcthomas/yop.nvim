vim.cmd([[
set rtp^=./vendor/plenary.nvim/
set rtp^=./vendor/matcher_combinators.lua/
set rtp^=../

runtime plugin/plenary.vim
]])

require('plenary.busted')
require('matcher_combinators.luassert')
vim.keymap.set(
  "n",
  ",",
  function()
    require("psy_op").create_operator(function(lines)
      for index, value in ipairs(lines) do
        lines[index] = "(" .. value .. ")"
      end
      return lines
    end)
  end
)
-- lua require('my_awesome_plugin').setup({ name = 'Jane Doe' })
