[![CI status][integration-badge]][integration-runs]

# YOP (_Y_our _OP_erator)

Make you some operators for great good!

```
Wait what's an Operator?
```

What's an operator you might ask. You've almost certainly been using them
already. An operator is any key that _operates_ over a selection of text,
selected either through a motion (ex: `iw` for in a word, `ab` around a
bracket, etc), or through a visual selection.

Some of the most common built in operators are 
- d: delete
- y: yank
- c: run selection through an external program

There're tons of less widely known operators too, and they're definitely worth
checking out! Run [:h operator][operator-help] to learn more.

```
Ok but what does _this_ plugin do?
```

Normally, defining an operator takes a bit of work, you'll have to get the text
covered by motion or visual selection, _*operate*_ on that text, and then
replace the text in the buffer. This plugin handles everything for you except
the operation, so that you can focus on what you really care about.

With YOP, all you need is a function that transforms and returns the selected
lines, or does some other super cool thing.

```
Alright, I'm sold! How do make my own operator?
```

<!-- TODO: finalize this api, do we want to handle the mapping for them? Or
just let them pass in the func itself-->


## Some fun example functions for inspiration!

Here's cool little example of a sorting operator, inspired heavily by the [sort
motion plugin][sort-motion], but with the added feature of asking the user for
a delimiter to split the line on.

### Sortin'!
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
    -- If only looking at 1 line, sort that line split by some char gotten from imput
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

Here's a real small little guy that'll search in telescope for the text passed
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


## Testing

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

## GitHub actions

On each PR and on Main, a GitHub Action will run all the tests, and the linter.
Tests will be run using [stable and nightly][neovim-test-versions] versions of
Neovim.

## What's in a name
```
It's a great plugin, but I really hate that name! Yop!? I mean, come on!
```

Well, here's a list of other names that were considered that you hopefully hate
a bit more!

- PSYOP
- MYOPIC
- MYOP
- YOUROP
- YOP
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
[integration-badge]: https://github.com/m00qek/plugin-template.nvim/actions/workflows/integration.yml/badge.svg
[integration-runs]: https://github.com/m00qek/plugin-template.nvim/actions/workflows/integration.yml
[neovim-test-versions]: .github/workflows/integration.yml#L17
[help]: doc/my-awesome-plugin.txt
[sort-motion]: https://github.com/christoomey/vim-sort-motion
[operator-help]: https://neovim.io/doc/user/motion.html#operator
