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

onoremap <Plug>(indent-object_linewise-none)  :<C-u>call <SID>handle_operator_mapping(0, 0, 0)<CR>
vnoremap <Plug>(indent-object_linewise-none)  :<C-u>call <SID>handle_visual_mapping(0, 0, 0)<CR>
onoremap <Plug>(indent-object_linewise-start) :<C-u>call <SID>handle_operator_mapping(1, 0, 0)<CR>
vnoremap <Plug>(indent-object_linewise-start) :<C-u>call <SID>handle_visual_mapping(1, 0, 0)<CR>
onoremap <Plug>(indent-object_linewise-end)   :<C-u>call <SID>handle_operator_mapping(0, 1, 0)<CR>
vnoremap <Plug>(indent-object_linewise-end)   :<C-u>call <SID>handle_visual_mapping(0, 1, 0)<CR>
onoremap <Plug>(indent-object_linewise-both)  :<C-u>call <SID>handle_operator_mapping(1, 1, 0)<CR>
vnoremap <Plug>(indent-object_linewise-both)  :<C-u>call <SID>handle_visual_mapping(1, 1, 0)<CR>

onoremap <Plug>(indent-object_blockwise-none)  :<C-u>call <SID>handle_operator_mapping(0, 0, 1)<CR>
vnoremap <Plug>(indent-object_blockwise-none)  :<C-u>call <SID>handle_visual_mapping(0, 0, 1)<CR>
onoremap <Plug>(indent-object_blockwise-start) :<C-u>call <SID>handle_operator_mapping(1, 0, 1)<CR>
vnoremap <Plug>(indent-object_blockwise-start) :<C-u>call <SID>handle_visual_mapping(1, 0, 1)<CR>
onoremap <Plug>(indent-object_blockwise-end)   :<C-u>call <SID>handle_operator_mapping(0, 1, 1)<CR>
vnoremap <Plug>(indent-object_blockwise-end)   :<C-u>call <SID>handle_visual_mapping(0, 1, 1)<CR>
onoremap <Plug>(indent-object_blockwise-both)  :<C-u>call <SID>handle_operator_mapping(1, 1, 1)<CR>
vnoremap <Plug>(indent-object_blockwise-both)  :<C-u>call <SID>handle_visual_mapping(1, 1, 1)<CR>

let s:last_range = {
			\ 'include_start': 0,
			\ 'include_end': 0,
			\ 'is_blockwise': 0,
			\ 'start': -1,
			\ 'end': -1,
			\ }

function! <SID>handle_operator_mapping(include_start, include_end, is_blockwise)
	call <SID>expand_range(
				\ {
					\ 'include_start': a:include_start,
					\ 'include_end': a:include_end,
					\ 'is_blockwise': a:is_blockwise,
					\ 'start': line("."),
					\ 'end': line("."),
					\ },
					\ v:count1,
					\ )
endfunction

function! <SID>handle_visual_mapping(include_start, include_end, is_blockwise)
	call <SID>expand_range(
				\ {
					\ 'include_start': a:include_start,
					\ 'include_end': a:include_end,
					\ 'is_blockwise': a:is_blockwise,
					\ 'start': line("'<"),
					\ 'end': line("'>"),
				\ },
				\ v:count1,
				\ )
endfunction

function! <SID>expand_range(initial_range, count)
	let counts_to_go = a:count " Curiously, count isn't allowed as a name.
	let range = copy(a:initial_range)

	" If the start and end of range requested by user are the same as seen the
	" last time, but it now also includes a delimiter that wasn't included
	" before, we add that delimiter and consume a count.
	if s:include_previously_excluded_delimiters(range)
		let counts_to_go -= 1

	" Otherwise, if is_blockwise is the only field of range that changed, just
	" consume a count, allowing user to toggle between the blockwise and
	" linewise types of selection.
	elseif s:only_blockwise_changed(range)
		let counts_to_go -= 1
	endif

	" If the supplied selection already contains all the lines having the same
	" or greater indent level as the outermost indent found in the selection,
	" we need to differentiate whether the selection was created manually by
	" user, or by our previous invocation. In the first case, we should leave
	" the selection untouched. Rationale: "dii" invoked on an indent
	" consisting of a single line should only delete that line, and not spill
	" outwards. In the second case, we need to expand outwards, or else
	" growing the selection with consecutive "ii"s in visual mode would not
	" work.
	let should_expand_outward = range == s:last_range

	let indent = s:find_outermost_indent_in_range(range.start, range.end)

	" If the range contained only blank lines, we need to look
	" above and below it to determine the indent.
	if indent == -1
		let indent = s:find_innermost_indent_adjacent_to_range(range.start, range.end)

		" Whole file is blank. Select all but the last line.
		if indent == -1
			let range.start = 1
			let range.end = max([line('$') - 1, 1])
			let counts_to_go = 0
		endif
	endif

	while counts_to_go > 0
		let old_range = copy(range)

		let range.start = s:expand_in_direction(range.start, indent, -1, range.include_start)
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
			let indent = s:find_innermost_indent_adjacent_to_range(range.start, range.end)
		else
			let counts_to_go -= 1
			let should_expand_outward = 1
		endif
	endwhile

	let s:last_range = range

	call s:set_cursor(range, indent)
endfunction

function! s:only_blockwise_changed(range)
	if s:last_range.is_blockwise == a:range.is_blockwise
		return 0
	elseif s:last_range.start != a:range.start
		return 0
	elseif s:last_range.end != a:range.end
		return 0
	elseif s:last_range.include_start != a:range.include_start
		return 0
	elseif s:last_range.include_end != a:range.include_end
		return 0
	endif

	return 1
endfunction

function! s:include_previously_excluded_delimiters(range)
	if a:range.start == s:last_range.start && a:range.end == s:last_range.end
		let changed = 0

		" If a delimiter wasn't previously included, or was and still is, we
		" can include previously excluded opposing delimiter, if requested.
		" Or conversely: if range *lost* a delimiter on one end, we assume user
		" wants to expand the selection to reach further outward, and not just
		" include previously excluded delimiter.
		if !s:last_range.include_end || a:range.include_end
			if !s:last_range.include_start && a:range.include_start
				let a:range.start -= 1
				let changed = 1
			endif
		endif
		if !s:last_range.include_start || a:range.include_start
			if !s:last_range.include_end && a:range.include_end
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
	" In a far-fetched case that user requested to include a delimiting
	" line, and its indent was smaller than that of the opposing
	" delimiting line, do not include the line. In other words: include
	" flag for a line only applies when that line actually delimits this
	" indent block.
	if a:range.include_start
		let closing_line = a:range.include_end ? a:range.end : nextnonblank(a:range.end + 1)
		let closing_indent = indent(closing_line)
		if indent(a:range.start) < closing_indent
			let a:range.start += 1
		endif
	endif

	if a:range.include_end
		let opening_line = a:range.include_start ? a:range.start : prevnonblank(a:range.start - 1)
		let opening_indent = indent(opening_line)
		if indent(a:range.end) < opening_indent
			let a:range.end -= 1
		endif
	endif
endfunction

function! s:set_cursor(range, outermost_indent)
	if &expandtab
		let outermost_first_char_column = a:outermost_indent + 1
	else
		let outermost_first_char_column = (a:outermost_indent / &tabstop) + 1
	endif

	call cursor(a:range.end, outermost_first_char_column)

	if a:range.is_blockwise
		exe "normal! \<C-v>"
		call cursor(a:range.start, outermost_first_char_column)
		exe "normal! _O$"
	else
		exe "normal! V"
		call cursor(a:range.start, outermost_first_char_column)
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
	let indent = v:numbermax
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

function! s:is_blank(lnum)
	return getline(a:lnum) =~ "^\\s*$"
endfunction
