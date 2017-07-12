" Maintainer: Kaiting Chen <ktchen14@gmail.com>

let s:database_name = get(g:, 'cscope_auto_database_name', 'cscope.out')

let s:dirsep = fnamemodify(getcwd(), ':p')[-1:]

" Return the nearest cscope database to the path by walking up the directory
" tree and looking for a file named according to cscope_auto_database_name. If
" there is no matching cscope database then return an empty string.
function! cscope_auto#locate_database(path)
  let path = fnamemodify(a:path, ':p:h')

  while !has_key(l:, 'last') || path !=# last
    if filereadable(path . s:dirsep . s:database_name)
      return path . s:dirsep . s:database_name
    endif
    let last = path
    let path = fnamemodify(path, ':h')
  endwhile
  return ''
endfunction

function! cscope_auto#id_list()
  return map(split(execute('cscope show'), '\n')[1:], "str2nr(matchstr(v:val, '\d\+'))")
endfunction

function! cscope_auto#switch_buffer(number)
  let name = bufname(a:number)

  if empty(getbufvar(a:number, '&buftype')) && !empty(name)
    let path = name
  else
    let path = getcwd()
  endif

  let database = cscope_auto#locate_database(path)

  if database ==# get(g:, 'cscope_auto_database', '')
    return
  endif

  if has_key(g:, 'cscope_auto_id')
    " Use silent! in case this was killed by the user
    silent! execute 'cscope kill ' . g:cscope_auto_id
    unlet g:cscope_auto_id
    unlet g:cscope_auto_database
  endif

  if empty(database) | return | endif

  let before = cscope_auto#id_list()
  execute 'cscope add ' . fnameescape(database)
  let result = cscope_auto#id_list()
  call filter(result, 'index(before, v:val) == -1')
  let g:cscope_auto_id = result[0]

  let g:cscope_auto_database = database
endfunction
