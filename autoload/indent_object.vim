"--------------------------------------------------------------------------------
"
"  Copyright (c) 2010 Michael Smith <msmith@msmith.id.au>
"
"  http://github.com/michaeljsmith/vim-indent-object
"
"  Permission is hereby granted, free of charge, to any person obtaining
"  a copy of this software and associated documentation files (the
"  "Software"), to deal in the Software without restriction, including without
"  limitation the rights to use, copy, modify, merge, publish, distribute,
"  sublicense, and/or sell copies of the Software, and to permit persons to whom
"  the Software is
"  furnished to do so, subject to the following conditions:
"
"  The above copyright notice and this permission notice shall be included in
"  all copies or substantial portions of the Software.
"
"  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
"  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
"  IN THE SOFTWARE.
"
"--------------------------------------------------------------------------------

" Fix for older versions of vim, where the variable is not defined.
let s:numbermax = exists("v:numbermax") ? v:numbermax : 1000000000000

let s:last_range = {
    \ 'include_start': 0,
    \ 'include_end': 0,
    \ 'is_blockwise': 0,
    \ 'keep': '',
    \ 'start': -1,
    \ 'end': -1,
    \ }

function! indent_object#handle_operator_mapping(
    \ include_start, include_end, is_blockwise, keep,
    \ )
    call s:expand_range(
        \ {
            \ 'include_start': a:include_start,
            \ 'include_end': a:include_end,
            \ 'is_blockwise': a:is_blockwise,
            \ 'keep': a:keep,
            \ 'start': line("."),
            \ 'end': line("."),
            \ },
            \ v:count1,
            \ )
endfunction

function! indent_object#handle_visual_mapping(
    \ include_start, include_end, is_blockwise, keep,
    \ )
    call s:expand_range(
        \ {
            \ 'include_start': a:include_start,
            \ 'include_end': a:include_end,
            \ 'is_blockwise': a:is_blockwise,
            \ 'keep': a:keep,
            \ 'start': line("'<"),
            \ 'end': line("'>"),
            \ },
            \ v:count1,
            \ )
endfunction

function! indent_object#repeat_visual_mapping()
    call s:expand_range(s:last_range, v:count1)
endfunction

function! s:expand_range(initial_range, count)
    let counts_to_go = a:count " Curiously, count isn't allowed as a name.
    let range = copy(a:initial_range)

    if s:last_range.is_blockwise
        if nextnonblank(s:last_range.start) == range.start
            if prevnonblank(s:last_range.end) == range.end
                " We want the blockwise selection not to include leading and
                " trailing blank lines, because they cause the indent common
                " to all lines in selection to be zero. To fix this, at the
                " end of the previous run we trimmed them from the visual
                " selection, but did not modify the s:last_range, so we can
                " now recover the real range.
                let range.start = s:last_range.start
                let range.end = s:last_range.end
            endif
        endif
    endif

    " If the supplied selection already contains all the lines having the same
    " or greater indent level as the outermost indent found in the selection,
    " we need to differentiate whether the selection was created manually by
    " user, or by our previous invocation. In the first case, we should leave
    " the selection untouched. Rationale: mapping to delete an indent level
    " consisting of a single line should only delete that line, and not spill
    " outwards. In the second case, we need to expand outwards, or else
    " growing the selection iteratively in visual mode would not work.
    " We initialize the flag with false and toggle it when necessary.
    let should_expand_outward = 0

    if range == s:last_range
        let should_expand_outward = 1

    elseif s:dicts_only_differ_in(s:last_range, range, ['keep'])
        " If user requests to to expand previous selection, this time keeping
        " one of its ends in place, we need to toggle the flag just like if
        " the two selections were the same (because they are, it's request
        " that's different).

        let should_expand_outward = 1

    elseif range.keep != "" && s:dicts_only_differ_in(s:last_range, range, [range.keep])
        " Both this and last run set "keep" flag to either "start" or "end".
        " Our algorithm ignores the flag during expansion phase, and takes it
        " into account only at the end, to set the visual selection. Because
        " of that, indent's start or end registered by the previous invocation
        " is different from the visual selection's start or end we got now,
        " and we need to:
        " - recall where the indent level starts or ends,
        " - toggle the flag just like if the two selections were the same,
        "   because -- internally -- they are.

        let range[range.keep] = s:last_range[range.keep]
        let should_expand_outward = 1

    elseif s:include_previously_excluded_delimiters(range)
        " If the start and end of range requested by user are the same as seen the
        " last time, but it now also includes a delimiter that wasn't included
        " before, we add that delimiter and consume a count.

        let counts_to_go -= 1

    elseif s:dicts_only_differ_in(s:last_range, range, ['is_blockwise'])
        " Otherwise, if is_blockwise is the only field of range that changed, just
        " consume a count, allowing user to toggle between the blockwise and
        " linewise types of selection.

        let counts_to_go -= 1
    endif

    let indent = s:find_outermost_indent_in_range(range.start, range.end)

    if indent == -1
        " If the range contained only blank lines, we need to look
        " above and below it to determine the indent.

        let indent = s:find_innermost_indent_adjacent_to_range(range.start, range.end)

        if indent == -1
            " Whole file is blank. Select all but the last line.
            let range.start = 1
            let range.end = max([line('$') - 1, 1])
            let counts_to_go = 0
        endif
    endif

    while counts_to_go > 0
        let old_range = copy(range)

        let range.start = s:expand_in_direction(
            \ range.start, indent, -1, range.include_start,
            \ )
        let range.end = s:expand_in_direction(range.end, indent, 1, range.include_end)

        call s:fix_delimiters(range)

        if old_range == range
            if !should_expand_outward
                let counts_to_go -= 1
                let should_expand_outward = 1
                continue
            endif

            " No point in further expansion if whole file is already in range.
            if range.start == 1 && range.end == line('$')
                break
            endif

            " Set indent to the innermost adjacent one, so next iteration
            " makes progress.
            let indent = s:find_innermost_indent_adjacent_to_range(
                \ range.start, range.end,
                \ )
        else
            let counts_to_go -= 1
            let should_expand_outward = 1
        endif
    endwhile

    if range.keep == "start"
        call s:set_visual_selection(
            \ a:initial_range.start, range.end, range.is_blockwise,
            \ )
    elseif range.keep == "end"
        call s:set_visual_selection(
            \ range.start, a:initial_range.end, range.is_blockwise,
            \ )
    else
        call s:set_visual_selection(range.start, range.end, range.is_blockwise)
    endif

    let s:last_range = range

endfunction

function! s:include_previously_excluded_delimiters(range)
    if a:range.start == s:last_range.start && a:range.end == s:last_range.end
        let changed = 0

        " We assume user doesn't want to expand the range outwards and just
        " wants to include a delimiter that wasn't included before when both
        " of the following conditions are true:
        " - if that delimiter wasn't included before, and now is (duh);
        " - the opposing delimiter either wasn't previously included, or was
        "   and still is.
        " Conversely, the second condition is: if range *lost* a delimiter on
        " one end, we assume user wants to expand the selection to reach
        " further outward, and not just include previously excluded delimiter.
        if !s:last_range.include_start && a:range.include_start
            if !s:last_range.include_end || a:range.include_end
                let a:range.start -= 1
                let changed = 1
            endif
        endif
        if !s:last_range.include_end && a:range.include_end
            if !s:last_range.include_start || a:range.include_start
                let a:range.end = nextnonblank(a:range.end + 1)
                let changed = 1
            endif
        endif

        if changed
            call s:fix_delimiters(a:range)
        endif

        return changed
    endif

endfunction

function! s:fix_delimiters(range)
    " In a far-fetched case that user requested to include a delimiting line,
    " and its indent was smaller than that of the opposing delimiting line, do
    " not include the line. In other words: include flag for a line only
    " applies when that line actually delimits this indent block.
    if a:range.include_start
        if a:range.include_end
            let closing_line = a:range.end
        else
            let closing_line = nextnonblank(a:range.end + 1)
        endif

        let closing_indent = indent(closing_line)
        if indent(a:range.start) < closing_indent
            let a:range.start += 1
        endif
    endif

    if a:range.include_end
        if a:range.include_start
            let opening_line = a:range.start
        else
            let opening_line = prevnonblank(a:range.start - 1)
        endif

        let opening_indent = indent(opening_line)
        if indent(a:range.end) < opening_indent
            let a:range.end -= 1
        endif
    endif
endfunction

function! s:set_visual_selection(start, end, is_blockwise)
    let start = a:is_blockwise ? nextnonblank(a:start) : a:start
    let end = a:is_blockwise ? prevnonblank(a:end) : a:end

    let outermost_indent = min([indent(start), indent(end)])

    if &expandtab
        let outermost_first_char_column = outermost_indent + 1
    else
        let outermost_first_char_column = (outermost_indent / &tabstop) + 1
    endif

    call cursor(start, outermost_first_char_column)

    if a:is_blockwise
        exe "normal! \<C-v>"
        call cursor(end, outermost_first_char_column)
        exe "normal! $"
    else
        exe "normal! V"
        call cursor(end, outermost_first_char_column)
    endif
endfunction

function! s:expand_in_direction(start, range_indent, direction, include_boundary)
    let current = a:start + a:direction
    let expanded = a:start
    let last_in_file = line('$')

    while current > 0 && current <= last_in_file
        if indent(current) >= a:range_indent || s:is_blank(current)
            let expanded = current
        else
            if a:include_boundary
                let expanded = current
            endif
            break
        endif

        let current += a:direction
    endwhile

    " Don't include the last trailing blank line.
    if a:direction == 1 && s:is_blank(expanded)
        let expanded -= 1
    endif

    return expanded
endfunction

function! s:find_innermost_indent_adjacent_to_range(start, end)
    let pnb = prevnonblank(a:start - 1)
    let pnb_indent = indent(pnb)

    let nnb = nextnonblank(a:end + 1)
    let nnb_indent = indent(nnb)

    return max([pnb_indent, nnb_indent])
endfunction

function! s:find_outermost_indent_in_range(start, end)
    let indent = s:numbermax
    let found = 0

    for line in range(a:start, a:end)
        if !s:is_blank(line)
            let indent = min([indent, indent(line)])
            let found = 1
        endif
    endfor

    " return -1 if all lines in range are blank
    return found ? indent : -1
endfunction

function! s:dicts_only_differ_in(first, second, different)
    " Note: we assume both dicts have the same keys.
    for [key, value] in items(a:first)
        if count(a:different, key) != 0
            if value == a:second[key]
                return 0
            endif
        else
            if value != a:second[key]
                return 0
            endif
        endif
    endfor

    return 1
endfunction

function! s:is_blank(lnum)
    return getline(a:lnum) =~ "^\\s*$"
endfunction
