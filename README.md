# vim-indent-object

This plugin provides text objects targeting indent levels, which is mainly
useful for working with whitespace-significant languages like Python. It also
allows targeting single delimiting lines above and below the indent level, which
is useful for languages with block end statements. It's a fork of
<http://github.com/michaeljsmith/vim-indent-object>. The original was forked
and rewritten to

  - hopefully make the code clearer,
  - add the blockwise objects that strip common indent from selection,
  - add mapping repeating last visual selection,
  - add mappings expanding one end of selection and keeping the other the same,
  - allow the closing delimiter to be selected independently,
  - handle mismatched delimiters better,
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

This plugin defines no mappings by default. You need to define them yourself.
For this, and for other info, see [the vim help documentation
file](doc/indent-object.txt).

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
