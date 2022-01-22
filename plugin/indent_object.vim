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

onoremap <silent> <Plug>(indent-object_linewise-none)  :<C-u>call indent_object#handle_operator_mapping(0, 0, 0, '')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-none)  :<C-u>call indent_object#handle_visual_mapping(0, 0, 0, '')<CR>
onoremap <silent> <Plug>(indent-object_linewise-start) :<C-u>call indent_object#handle_operator_mapping(1, 0, 0, '')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-start) :<C-u>call indent_object#handle_visual_mapping(1, 0, 0, '')<CR>
onoremap <silent> <Plug>(indent-object_linewise-end)   :<C-u>call indent_object#handle_operator_mapping(0, 1, 0, '')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-end)   :<C-u>call indent_object#handle_visual_mapping(0, 1, 0, '')<CR>
onoremap <silent> <Plug>(indent-object_linewise-both)  :<C-u>call indent_object#handle_operator_mapping(1, 1, 0, '')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-both)  :<C-u>call indent_object#handle_visual_mapping(1, 1, 0, '')<CR>

onoremap <silent> <Plug>(indent-object_blockwise-none)  :<C-u>call indent_object#handle_operator_mapping(0, 0, 1, '')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-none)  :<C-u>call indent_object#handle_visual_mapping(0, 0, 1, '')<CR>
onoremap <silent> <Plug>(indent-object_blockwise-start) :<C-u>call indent_object#handle_operator_mapping(1, 0, 1, '')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-start) :<C-u>call indent_object#handle_visual_mapping(1, 0, 1, '')<CR>
onoremap <silent> <Plug>(indent-object_blockwise-end)   :<C-u>call indent_object#handle_operator_mapping(0, 1, 1, '')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-end)   :<C-u>call indent_object#handle_visual_mapping(0, 1, 1, '')<CR>
onoremap <silent> <Plug>(indent-object_blockwise-both)  :<C-u>call indent_object#handle_operator_mapping(1, 1, 1, '')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-both)  :<C-u>call indent_object#handle_visual_mapping(1, 1, 1, '')<CR>

onoremap <silent> <Plug>(indent-object_linewise-none-keep-start) :<C-u>call indent_object#handle_operator_mapping(0, 0, 0, 'start')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-none-keep-start) :<C-u>call indent_object#handle_visual_mapping(0, 0, 0, 'start')<CR>
onoremap <silent> <Plug>(indent-object_linewise-end-keep-start)  :<C-u>call indent_object#handle_operator_mapping(0, 1, 0, 'start')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-end-keep-start)  :<C-u>call indent_object#handle_visual_mapping(0, 1, 0, 'start')<CR>

onoremap <silent> <Plug>(indent-object_linewise-none-keep-end)  :<C-u>call indent_object#handle_operator_mapping(0, 0, 0, 'end')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-none-keep-end)  :<C-u>call indent_object#handle_visual_mapping(0, 0, 0, 'end')<CR>
onoremap <silent> <Plug>(indent-object_linewise-start-keep-end) :<C-u>call indent_object#handle_operator_mapping(1, 0, 0, 'end')<CR>
xnoremap <silent> <Plug>(indent-object_linewise-start-keep-end) :<C-u>call indent_object#handle_visual_mapping(1, 0, 0, 'end')<CR>

onoremap <silent> <Plug>(indent-object_blockwise-none-keep-start) :<C-u>call indent_object#handle_operator_mapping(0, 0, 1, 'start')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-none-keep-start) :<C-u>call indent_object#handle_visual_mapping(0, 0, 1, 'start')<CR>
onoremap <silent> <Plug>(indent-object_blockwise-end-keep-start)  :<C-u>call indent_object#handle_operator_mapping(0, 1, 1, 'start')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-end-keep-start)  :<C-u>call indent_object#handle_visual_mapping(0, 1, 1, 'start')<CR>

onoremap <silent> <Plug>(indent-object_blockwise-none-keep-end)  :<C-u>call indent_object#handle_operator_mapping(0, 0, 1, 'end')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-none-keep-end)  :<C-u>call indent_object#handle_visual_mapping(0, 0, 1, 'end')<CR>
onoremap <silent> <Plug>(indent-object_blockwise-start-keep-end) :<C-u>call indent_object#handle_operator_mapping(1, 0, 1, 'end')<CR>
xnoremap <silent> <Plug>(indent-object_blockwise-start-keep-end) :<C-u>call indent_object#handle_visual_mapping(1, 0, 1, 'end')<CR>

xnoremap <silent> <Plug>(indent-object_repeat) :<C-u>call indent_object#repeat_visual_mapping()<CR>
