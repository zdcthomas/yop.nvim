[![CI status][integration-badge]][integration-runs]

# YOP (_Y_our _OP_erator)

## Quickstart

Here are some snippets for your plugin manager of choice. These implement only
the [sorting](#Sortin) operator.

Packer:
```lua
use("zdcthomas/yop.nvim/")
```

Vim-Plug:
```VimL
Plug 'zdcthomas/yop.nvim'
```

## What is this?

This is a plugin that allows you to easily make you some operators for great good!

> Wait what's an Operator?

What's an operator you might ask. You've almost certainly been using them
already. An operator is any key that _operates_ over a selection of text,
selected either through a motion (ex: `iw`: in-a-word, `ab`: around-a-bracket,
etc), or through a visual selection.

Some of the most common built in operators are 
- `d`: delete
- `y`: yank
- `c`: run selection through an external program

There're tons of less widely known operators too, and they're definitely worth
checking out! Run [:h operator][operator-help] to learn more.

> Ok but what does _this_ plugin do?

Normally, defining an operator takes a bit of work, you'll have to get the text
covered by motion or visual selection, _*operate*_ on that text, and then
replace the text in the buffer. This plugin handles everything for you except
the operation, so you can focus on what you really care about.

With YOP, all you need is a function that transforms and returns the selected
lines, or does some other super cool thing.

> Alright, I'm sold! How do make my own operator?

### Making your own operators

The primary interface for `yop.nvim` is the `op_map` function.
```lua
require("yop").op_map
```

This function takes the same arguments as [vim.keymap.set][keymap.set], except
that the 3rd argument (normally either a function or a string representing a
vim command), now has to be a function that looks like:
```lua
function (selected_lines, info)
  ...
  return optional_replacement_lines
end
```
where:
- selected_lines: Table of strings, which represent the text that was moved over by the given motion. 
- info: a table with extra info about the motion. (Most of the time you won't
  need this and can just pass in a 1-arity function)
  ```lua
  {
    position = {
      first = {row_number, column_number},
      last = {row_number, column_number},
    },
    type = motion_callback_type
  }
  ```
  Row_number and column_number are 1-indexed integers, motion_callback_type is one of `line`|`char`|`block`

- optional_replacement_lines: The function can optionally return a table of lines, which will replace the
selected region in the buffer.

> **Note**
> Remember, in Lua, you can ignore extra arguments by simply not listing them
> in the declaration. This means that you can pass in a 0-arity, 1-arity, or 2-arity
> function and all will work!

For some example transformation functions, see [the examples section](#Examples)

### Putting it all together

A full (but useless) example might look like:
```lua
require("yop").op_map({"n", "v"}, "<leader>b", function(lines, info)
  return { "bread" }
end)
```
This example simply replaces the entire selected area with the text `bread`.
On a buffer that looks like
```
1 2 3
4 5 6
7 8 9
```

With your cursor on `1` type in `<leader>bw`. Now `{ "1 2"}` will be passed in
as the first argument to the function you passed into. We could also type
`vw<leader>b`, and since we told `op_map` that we'd also like this mapping to
exist in visual mode, it will behave identically.

Afterward, the buffer will look like:
```
bread 3
4 5 6
7 8 9
```


If instead, you type `<leader>bj`, then lines will be `{"1 2 3", "4 5 6"}`
because `j` is a line wise motion. This is the same as if you entered visual
line mode with `V` and selected the top two lines before hitting `<leader>b`.
The buffer will then become
```
bread
7 8 9
```


> **Warning**
> The following api is very likely to change, because it sucks, and I hate it.

A linewise version of the same function can also be created by including
`linewise = true` in the third argument opts. This has to be a different
mapping, since this includes a motion along with the operator. It also must be
in normal mode For example,
```lua
require("yop").op_map("n", "<leader>bb", function(lines, info)
  return { "bread" }
end, {linewise = true})
```

This allows you to run `<leader>bb` on the first line in this example
buffer, and change it to:
```
bread
4 5 6
7 8 9
```

## Examples

Here's cool little example of a sorting operator, inspired heavily by the
[sort motion plugin][sort-motion], but with the added feature of asking the
user for a delimiter to split the line on.

### Sortin!
```lua
function(lines, opts)
  -- We don't care about anything non alphanumeric here
  local sort_without_leading_space = function(a, b)
    -- true = a then b
    -- false = b then a
    local pattern = [[^%W*]]
    return string.gsub(a, pattern, "") < string.gsub(b, pattern, "")
  end
  if #lines == 1 then
    -- If only looking at 1 line, sort that line split by some char gotten from input
    local delimeter = utils.get_input("Delimeter: ")
    local split = vim.split(lines[1], delimeter, { trimempty = true })
    -- Remember! `table.sort` mutates the table itself
    table.sort(split, sort_without_leading_space)
    return { utils.join(split, delimeter) }
  else
    -- If there are many lines, sort the lines themselves
    table.sort(lines, sort_without_leading_space)
    return lines
  end
end
```

### Searchin!

> **Note**
> This requires [Telescope][telescope] to be installed

Here's a real small little guy that'll search in [telescope][telescope] for the text passed
over in a motion, or selected visually.

```lua
function(lines)
  -- Multiple lines can't be searched for
  if #lines > 1 then
    return
  end
  require("telescope.builtin").grep_string({ search = lines[1] })
end
```

## Contributing! (Thank you!)

Please feel free to contribute!

### Testing

This uses [busted][busted], [luassert][luassert] (both through
[plenary.nvim][plenary]) and [matcher_combinators][matcher_combinators] to
define tests in `test/spec/` directory. These dependencies are required only to
run tests, that's why they are installed as git submodules.

Make sure your shell is in the `./test` directory or, if it is in the root directory,
replace `make` by `make -C ./test` in the commands below.

To init the dependencies run

```bash
$ make prepare
```

To run all tests just execute

```bash
$ make test
```

If you have [entr(1)][entr] installed you may use it to run all tests whenever a
file is changed using:

```bash
$ make watch
```

In both commands you myght specify a single spec to test/watch using:

### GitHub actions

On each PR and on Main, a GitHub Action will run all the tests, and the linter.
Tests will be run using [stable and nightly][neovim-test-versions] versions of
Neovim.

### What's in a name
> It's a great plugin, but I really hate that name! Yop!? I mean, come on!

Well, here's a list of other names that were considered that you hopefully hate
a bit more!

- PSYOP
- MYOPIC
- MYOP
- YOUROP
- OPPENHEIMER
- YOPTIMUS PRIME
- OPTIMUS PRIME
- YOPOLOPOLIS
- POP


[lua]: https://www.lua.org/
[entr]: https://eradman.com/entrproject/
[luarocks]: https://luarocks.org/
[busted]: https://olivinelabs.com/busted/
[luassert]: https://github.com/Olivine-Labs/luassert
[plenary]: https://github.com/nvim-lua/plenary.nvim
[matcher_combinators]: https://github.com/m00qek/matcher_combinators.lua
[integration-badge]: https://github.com/zdcthomas/yop.nvim/actions/workflows/integration.yml/badge.svg
[integration-runs]: https://github.com/zdcthomas/yop.nvim/actions/workflows/integration.yml
[neovim-test-versions]: .github/workflows/integration.yml#L17
[help]: doc/my-awesome-plugin.txt
[sort-motion]: https://github.com/christoomey/vim-sort-motion
[operator-help]: https://neovim.io/doc/user/motion.html#operator
[telescope]: https://github.com/nvim-telescope/telescope.nvim
[keymap.set]: https://neovim.io/doc/user/lua.html#vim.keymap.set()
