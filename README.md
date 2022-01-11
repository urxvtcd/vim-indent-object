# vim-indent-object

This plugin provides text objects targeting indent levels, which is mainly
useful for working with whitespace-significant languages like Python. It also
allows tageting single delimiting lines above and below the indent level, which
is useful for languages with block end statements. It's a fork of
<http://github.com/michaeljsmith/vim-indent-object>. The original was forked
and rewritten to
  - hopefully make the code clearer,
  - add the blockwise objects that strip common indent from selection,
  - add mapping repeating last visual selection,
  - allow the closing delimiter to be selected independently,
  - handle mismatched delimiters better,
  - move from hardcoded mappings to `<Plug>` ones,
  - and back all of this up with tests using Vader framework.

## Install

You know how to do it.

## Usage

Because of DRY, see [vim help documentation file](doc/indent-object.txt).

## Credits

vim-indent-object was originally written by Michael Smith
<msmith@msmith.id.au>. While the rewrite is nearly total, it was much easier to
iterate on something that already worked.
