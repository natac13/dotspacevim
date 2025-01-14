" vim: fileencoding=utf-8 foldmethod=marker foldlevel=0:

function! myspacevim#before() abort " {{{
    if filereadable($HOME . "/.spacevim.local")
        exec "source " . $HOME . "/.spacevim.local"
    endif

    call s:setup_conemu()
    call s:setup_lsp()
    call myspacevim#colorscheme#autoload()

    " Global configurations {{{
    " Add rooter for haskell
    call add(g:spacevim_project_rooter_patterns, 'stack.yaml')
    " }}}

    call s:setup_mapping()
    call s:setup_plugin()
    call s:setup_autocmd()
endfunction " }}}

function! myspacevim#after() abort " {{{
    set ignorecase
    set smartcase
    set wildmode=longest:full,full
    set wildmenu
    " Fix compatibility of CJK long lines.
    set nolinebreak

    call s:setup_plugin_after()
endfunction " }}}

function! myspacevim#IncludePathHook(config) " {{{
    if has_key(a:config, 'c_include_path')
        let p = a:config['c_include_path']
        if type(p) == type("")
            let raw_path = has('win32') ? tr(p, '\', '/') : p
            let paths = split(escape(p]\)\@!')
            let &l:path .= ',' . join(paths, ',')
        endif
    endif
endfunction " }}}

function! s:goyo_enter() " {{{
    if executable('tmux')
        silent !tmux set status off
        silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
    endif
endfunction " }}}

function! s:goyo_leave() " {{{
    if executable('tmux')
        silent !tmux set status on
        silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
    endif
endfunction " }}}

function! s:setup_lsp() " {{{
    let lsp_servers = {
                \ 'c' : 'clangd',
                \ 'cpp' : 'clangd',
                \ 'css' : 'css-languageserver',
                \ 'dart' : 'dart_language_server',
                \ 'dockerfile' : 'docker-langserver',
                \ 'go' : 'go-langserver',
                \ 'haskell' : 'hie-wrapper',
                \ 'html' : 'html-languageserver',
                \ 'javascript' : 'javascript-typescript-stdio',
                \ 'julia' : 'julia',
                \ 'objc' : 'clangd',
                \ 'objcpp' : 'clangd',
                \ 'php' : 'php',
                \ 'purescript' : 'purescript-language-server',
                \ 'python' : 'pyls',
                \ 'rust' : 'rustup',
                \ 'sh' : 'bash-language-server',
                \ 'typescript' : 'typescript-language-server',
                \ 'ruby' : 'solargraph.BAT',
                \ 'vue' : 'vls',
                \ }

    let filetypes = []

    for lang in keys(lsp_servers)
        if executable(lsp_servers[lang])
            call add(filetypes, lang)
        endif
    endfor

    call SpaceVim#layers#lsp#set_variable({
                \ 'filetypes' : filetypes,
                \ })
endfunction " }}}

function! s:setup_conemu() " {{{
    if &term=='win32' && !empty($ConEmuANSI)
        " echom "Running in conemu"
        " Should ``chcp 65001`` in console
        set termencoding=utf8
        set term=xterm
        set t_Co=256
        let &t_AB="\e[48;5;%dm"
        let &t_AF="\e[38;5;%dm"
        let g:spacevim_enable_guicolors=0
        let g:spacevim_colorscheme_default = "onedark"
    endif
endfunction
" }}}

function! s:setup_mapping() " {{{
    nnoremap zJ zjzx
    nnoremap zK zkzx
endfunction
" }}}

function! s:setup_plugin() " {{{
    "" deoplete.vim {{{
    let g:deoplete#auto_complete_delay = 150
    "" }}}

    "" dein.vim {{{
    " Do a shallow clone
    let g:dein#types#git#clone_depth = 1
    "" }}}

    "" Projectionist {{{
    let g:projectionist_heuristics = {
                \ 'Makefile': {
                \   '*': {'make': 'make'},
                \ },
                \ 'Jamroot|Jamroot.v2': {
                \   '*': {'make': 'b2'},
                \ },
                \ }
    "" }}}

    "" clang2 {{{
    let g:clang2_placeholder_next = ''
    let g:clang2_placeholder_prev = ''
    "" }}}

    "" Neomake {{{
    let g:neomake_vim_enabled_makers = []

    if executable('vimlint')
        call add(g:neomake_vim_enabled_makers, 'vimlint')
    endif
    if executable('vint')
        call add(g:neomake_vim_enabled_makers, 'vint')
    endif
    "" }}}

    "" ultisnips {{{
    let g:ultisnips_python_quoting_style = "single"
    let g:ultisnips_python_triple_quoting_style = "double"
    let g:ultisnips_python_style = "google"
    "" }}}

    "" vim-pydocstring {{{
    let g:pydocstring_templates_dir = '~/.SpaceVim.d/templates/pydocstring/google'
    "" }}}

    "" Tagbar {{{
    let g:tagbar_autofocus = 1
    "" }}}

    "" Startify {{{
    let g:startify_custom_header = ['   Welcome to SpaceVim!']
    "" }}}

    "" Unite {{{
    if exists('*unite#custom#source')
        call unite#custom#source(
                    \ 'file_rec,file_rec/async,grep',
                    \ 'ignore_pattern',
                    \ join([
                    \ '\%(^\|/\)\.$',
                    \ '\~$',
                    \ '\.\%(o\|a\|exe\|dll\|bak\|DS_Store\|zwc\|pyc\|sw[po]\|class\|gcno\|gcda\|gcov\)$',
                    \ '\%(^\|/\)gcc-[0-9]\+\%(\.[0-9]\+\)*/',
                    \ '\%(^\|/\)doc/html/',
                    \ '\%(^\|/\)stage/',
                    \ '\%(^\|/\)boost\%(\|_\w\+\)/',
                    \ '\%(^\|/\)\%(\.hg\|\.git\|\.bzr\|\.svn\|tags\%(-.*\)\?\)\%($\|/\)',
                    \ ], '\|'))
    endif
    "" }}}

    "" vim-asciidoc-folding {{{
    let g:asciidoc_fold_style = 'nested'
    let g:asciidoc_fold_override_foldtext = 1
    "" }}}

    "" vim-markdown {{{
    "let g:markdown_default_mappings = 1
    let g:vim_markdown_auto_insert_bullets = 0
    "let g:markdown_hi_error = 1
    "" }}}

    "" vim-markdown-folding {{{
    let g:markdown_fold_style = 'nested'
    let g:markdown_fold_override_foldtext = 1
    "" }}}

    "" vim-bracketed-paste {{{
    let g:bracketed_paste_tmux_wrap = 0
    "" }}}

    "" vim-fswitch {{{
    let g:fsnonewfiles=1
    " 可以用:A在.h/.cpp间切换
    augroup myspacevim_fswitch
        autocmd!

        autocmd! BufEnter *.h,*.hpp
                    \  let b:fswitchdst='cpp,c,ipp,cxx'
                    \| let b:fswitchlocs='reg:/include/src/,reg:/include.*/src/,ifrel:|/include/|../src|,reg:!\<include/\w\+/!src/!,reg:!\<include/\(\w\+/\)\{2}!src/!,reg:!\<include/\(\w\+/\)\{3}!src/!,reg:!\<include/\(\w\+/\)\{4}!src/!,reg:!sscc\(/[^/]\+\|\)/.*!libs\1/**!'
        autocmd! BufEnter *.c,*.cpp,cxx,*.ipp
                    \  let b:fswitchdst='h,hpp'
                    \| let b:fswitchlocs='reg:/src/include/,reg:|/src|/include/**|,ifrel:|/src/|../include|,reg:|libs/.*|**|'
        autocmd! BufEnter *.xml
                    \  let b:fswitchdst='rnc'
                    \| let b:fswitchlocs='./'
        autocmd! BufEnter *.rnc
                    \  let b:fswitchdst='xml'
                    \| let b:fswitchlocs='./'

        autocmd! FileType c,cpp,xml,rnc
                    \  nnoremap <buffer> [SPC]lja :FSHere<CR>
                    \| nnoremap <buffer> [SPC]ljA :FSSplitRight<CR>
                    \| nnoremap <buffer> [SPC]ljl :FSRight<CR>
                    \| nnoremap <buffer> [SPC]ljL :FSSplitRight<CR>
                    \| nnoremap <buffer> [SPC]ljh :FSLeft<CR>
                    \| nnoremap <buffer> [SPC]ljH :FSSplitLeft<CR>
                    \| nnoremap <buffer> [SPC]ljk :FSAbove<CR>
                    \| nnoremap <buffer> [SPC]ljK :FSSplitAbove<CR>
                    \| nnoremap <buffer> [SPC]ljj :FSBelow<CR>
                    \| nnoremap <buffer> [SPC]ljJ :FSSplitBelow<CR>
                    \| command! -buffer A :call FSwitch('%', '')
    augroup END
    "" }}}

    "" CodeReviewer.vim {{{
    call SpaceVim#custom#SPC('nmap', ['i'], '<Plug>AddComment', 'Insert code review comment', 0)

    if $USER != ""
        let g:CodeReviewer_reviewer = $USER
    elseif $USERNAME != ""
        let g:CodeReviewer_reviewer = $USERNAME
    else
        let g:CodeReviewer_reviewer = "Unknown"
    endif

    let g:CodeReviewer_reviewFile="review.rev"
    "" }}}

    "" NERD_commenter.vim {{{
    call SpaceVim#custom#SPC('nmap', ['c', 'c'], '<Plug>NERDCommenterToggle', 'comment or uncomment lines(aligned)', 0)
    "" }}}

endfunction
" }}}

function! s:setup_autocmd() " {{{
    augroup myspacevim_jam
        autocmd!
        autocmd! BufEnter Jamroot,Jamfile,Jamroot.v2,Jamfile.v2,*.jam :set filetype=jam
        autocmd! BufEnter Jamroot,Jamfile,Jamroot.v2,Jamfile.v2 :compiler b2
        autocmd! FileType jam
                    \  nnoremap <buffer> [SPC]lb :make<CR>
                    \| nnoremap <buffer> [SPC]lt :make unittest<CR>
    augroup END

    augroup myspacevim_cpp
        autocmd!
        autocmd! FileType c,cpp
                    \  nnoremap <buffer> [SPC]lb :make<CR>
                    \| nnoremap <buffer> [SPC]lt :make unittest<CR>
    augroup END

    augroup myspacevim_asciidoc
        autocmd!
        autocmd! FileType asciidoc
                    \  :set foldlevel=0
    augroup END

    augroup myspacevim_markdown
        autocmd!
        autocmd! FileType markdown
                    \  :set foldlevel=1 shiftwidth=2
                    \| :command! -buffer -range=% ReBullet silent! %s/^\(  \(    \)*\)\* /\1- / <bar> silent! %s/^\(\(    \)*\)\- /\1* /
    augroup END

    augroup myspacevim_haskell
        autocmd!
        autocmd! FileType haskell
                    \  :set shiftwidth=2 expandtab
    augroup END

    " surround
    augroup myspacevim_surround_markdown
        autocmd!

        autocmd! FileType markdown :let b:surround_96 = "``\r``"
    augroup END
    
    " Goyo, Distraction-free writing in Vim
    augroup myspacevim_goyo
        autocmd! User GoyoEnter nested call <SID>goyo_enter()
        autocmd! User GoyoLeave nested call <SID>goyo_leave()
    augroup END

endfunction
" }}}

function! s:setup_plugin_after() " {{{
    call editorconfig#AddNewHook(function('myspacevim#IncludePathHook'))

    if exists('*unite#filters#matcher_default#use')
        call unite#filters#matcher_default#use(['matcher_context'])
    endif

    if exists('*unite#custom#profile')
        call unite#custom#profile('default', 'context', {
                    \   'direction': 'botright',
                    \ })
    endif

    if exists('*denite#custom#source')
        call denite#custom#source('_'])
    endif

    if exists('*denite#custom#option')
        call denite#custom#option('default', {
                    \ 'direction' : 'botright',
                    \ })
    endif

    "" Mark--Karkat {{{
    nmap <silent><unique> <Leader>mm <Plug>MarkSet
    xmap <silent><unique> <Leader>mm <Plug>MarkSet
    nmap <silent><unique> <Leader>mr <Plug>MarkRegex
    xmap <silent><unique> <Leader>mr <Plug>MarkRegex
    nmap <silent><unique> <Leader>mc <Plug>MarkClear
    nmap <silent><unique> <Leader>mM <Plug>MarkToggle
    nmap <silent><unique> <Leader>mC <Plug>MarkAllClear

    nmap <silent><unique> <Leader>mn <Plug>MarkSearchCurrentNext
    nmap <silent><unique> <Leader>mp <Plug>MarkSearchCurrentPrev
    nmap <silent><unique> <Leader>mN <Plug>MarkSearchAnyNext
    nmap <silent><unique> <Leader>mP <Plug>MarkSearchAnyPrev
    nmap <silent><unique> <Plug>IgnoreMarkSearchNext <Plug>MarkSearchNext
    nmap <silent><unique> <Plug>IgnoreMarkSearchPrev <Plug>MarkSearchPrev

    highlight MarkWord1 ctermbg=DarkCyan    ctermfg=Black guibg=#8CCBEA guifg=Black |
    highlight MarkWord2 ctermbg=DarkMagenta ctermfg=Black guibg=#FF7272 guifg=Black |
    highlight MarkWord3 ctermbg=DarkYellow  ctermfg=Black guibg=#FFDB72 guifg=Black |
    highlight MarkWord4 ctermbg=DarkGreen   ctermfg=Black guibg=#FFB3FF guifg=Black |
    highlight MarkWord5 ctermbg=DarkRed     ctermfg=Black guibg=#9999FF guifg=Black |
    highlight MarkWord6 ctermbg=DarkBlue    ctermfg=Black guibg=#A4E57E guifg=Black
    "" }}}
endfunction
" }}}

" command SyntaxId {{{
function! s:syntax_id()
    let s = []
    for id in synstack(line("."), col("."))
        call add(s, synIDattr(id, "name"))
    endfor
    echo join(s, ' -> ')
endfunction
command! SyntaxId call s:syntax_id()
" }}}

