# vim-indent-object

This plugin provides text objects targeting indent levels, which is mainly
useful for working with whitespace-significant languages like Python. It also
allows targeting single delimiting lines above and below the indent level, which
is useful for languages with block end statements. It's a fork of
<http://github.com/michaeljsmith/vim-indent-object>. The original was forked
and rewritten to

  - hopefully make the code clearer,
  - add the blockwise objects that select text without indent that is common to
    all the selected lines,
  - add mapping repeating last visual selection,
  - add mappings expanding one end of selection and keeping the other the same,
  - add mappings selecting a range and its closing delimiter line (a line
    following the selection that has smaller indent than the selection),
  - handle mismatched opening and closing delimiters better,
  - move from hard-coded mappings to `<Plug>` ones,
  - use on-demand loading via vim's autoload feature,
  - move from `vmap` and `vnoremap` to `xmap` and `xnoremap`,
  - and back all of this up with tests using
    [Vader](https://github.com/junegunn/vader.vim) framework.

## Demo

[![asciicast](https://asciinema.org/a/465213.svg)](https://asciinema.org/a/465213?autoplay=1)

## Install

You know how to do it.

## Usage

**This plugin defines no mappings by default.** You need to define them
yourself. Though most people will probably be happy with just the most basic
ones:

```vim
xmap ii <Plug>(indent-object_linewise-none)
omap ii <Plug>(indent-object_blockwise-none)
```

The mapping above selects all lines with the same or greater indent level. It
works in both visual mode (try typing `vii` in normal mode) and
operator-pending mode (try typing `dii` in normal mode).

To make it possible to expand the selection outward, you need to add the
following mapping as well:

```vim
xmap <C-o> <Plug>(indent-object_repeat)
```

See [the vim help documentation file](doc/indent-object.txt) for many more
mappings.

## Tests

You need to have this plugin and Vader installed. To run tests in an isolated
environment run:

    tests/run.sh

You can also run them from inside Vim by issuing command `:Vader tests/*`, but
the results can be tainted by your configuration, and the state of the editor.

## Credits

vim-indent-object was originally written by Michael Smith
<msmith@msmith.id.au>. While the rewrite is nearly total, it was much easier to
iterate on something that already worked.
