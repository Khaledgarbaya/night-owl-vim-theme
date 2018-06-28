" night-owl color scheme ported from https://github.com/sdras/night-owl-vscode-theme
" Author: Khaled Garbaya @khaled_garbaya
" Maintainer: Khaled Garbaya <khaledgarbaya@gmail.com>
" Notes: To check the meaning of the highlight groups, :help 'highlight'
"
set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "night-owl"

if has("gui_running") || &t_Co == 88 || &t_Co == 256
  let s:low_color = 0
else
  let s:low_color = 1
endif

" Color approximation functions by Henry So, Jr. and David Liang

" returns an approximate grey index for the given grey level
fun! s:grey_number(x)
  if &t_Co == 88
    if a:x < 23
      return 0
    elseif a:x < 69
      return 1
    elseif a:x < 103
      return 2
    elseif a:x < 127
      return 3
    elseif a:x < 150
      return 4
    elseif a:x < 173
      return 5
    elseif a:x < 196
      return 6
    elseif a:x < 219
      return 7
    elseif a:x < 243
      return 8
    else
      return 9
    endif
  else
    if a:x < 14
      return 0
    else
      let l:n = (a:x - 8) / 10
      let l:m = (a:x - 8) % 10
      if l:m < 5
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual grey level represented by the grey index
fun! s:grey_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 46
    elseif a:n == 2
      return 92
    elseif a:n == 3
      return 115
    elseif a:n == 4
      return 139
    elseif a:n == 5
      return 162
    elseif a:n == 6
      return 185
    elseif a:n == 7
      return 208
    elseif a:n == 8
      return 231
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 8 + (a:n * 10)
    endif
  endif
endfun

" returns the palette index for the given grey index
fun! s:grey_color(n)
  if &t_Co == 88
    if a:n == 0
      return 16
    elseif a:n == 9
      return 79
    else
      return 79 + a:n
    endif
  else
    if a:n == 0
      return 16
    elseif a:n == 25
      return 231
    else
      return 231 + a:n
    endif
  endif
endfun

" returns an approximate color index for the given color level
fun! s:rgb_number(x)
  if &t_Co == 88
    if a:x < 69
      return 0
    elseif a:x < 172
      return 1
    elseif a:x < 230
      return 2
    else
      return 3
    endif
  else
    if a:x < 75
      return 0
    else
      let l:n = (a:x - 55) / 40
      let l:m = (a:x - 55) % 40
      if l:m < 20
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual color level for the given color index
fun! s:rgb_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 139
    elseif a:n == 2
      return 205
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 55 + (a:n * 40)
    endif
  endif
endfun

" returns the palette index for the given R/G/B color indices
fun! s:rgb_color(x, y, z)
  if &t_Co == 88
    return 16 + (a:x * 16) + (a:y * 4) + a:z
  else
    return 16 + (a:x * 36) + (a:y * 6) + a:z
  endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun! s:color(r, g, b)
  " get the closest grey
  let l:gx = s:grey_number(a:r)
  let l:gy = s:grey_number(a:g)
  let l:gz = s:grey_number(a:b)

  " get the closest color
  let l:x = s:rgb_number(a:r)
  let l:y = s:rgb_number(a:g)
  let l:z = s:rgb_number(a:b)

  if l:gx == l:gy && l:gy == l:gz
    " there are two possibilities
    let l:dgr = s:grey_level(l:gx) - a:r
    let l:dgg = s:grey_level(l:gy) - a:g
    let l:dgb = s:grey_level(l:gz) - a:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_level(l:gx) - a:r
    let l:dg = s:rgb_level(l:gy) - a:g
    let l:db = s:rgb_level(l:gz) - a:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      " use the grey
      return s:grey_color(l:gx)
    else
      " use the color
      return s:rgb_color(l:x, l:y, l:z)
    endif
  else
    " only one possibility
    return s:rgb_color(l:x, l:y, l:z)
  endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun! s:rgb(rgb)
  let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
  let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
  let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
  return s:color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun! s:X(group, fg, bg, attr, lcfg, lcbg)
  if s:low_color
    let l:fge = empty(a:lcfg)
    let l:bge = empty(a:lcbg)

    if !l:fge && !l:bge
      exec "hi ".a:group." ctermfg=".a:lcfg." ctermbg=".a:lcbg
    elseif !l:fge && l:bge
      exec "hi ".a:group." ctermfg=".a:lcfg." ctermbg=NONE"
    elseif l:fge && !l:bge
      exec "hi ".a:group." ctermfg=NONE ctermbg=".a:lcbg
    endif
  else
    let l:fge = empty(a:fg)
    let l:bge = empty(a:bg)

    if !l:fge && !l:bge
      exec "hi ".a:group." guifg=#".a:fg." guibg=#".a:bg." ctermfg=".s:rgb(a:fg)." ctermbg=".s:rgb(a:bg)
    elseif !l:fge && l:bge
      exec "hi ".a:group." guifg=#".a:fg." guibg=NONE ctermfg=".s:rgb(a:fg)." ctermbg=NONE"
    elseif l:fge && !l:bge
      exec "hi ".a:group." guifg=NONE guibg=#".a:bg." ctermfg=NONE ctermbg=".s:rgb(a:bg)
    endif
  endif

  if a:attr == ""
    exec "hi ".a:group." gui=none cterm=none"
  else
    let l:noitalic = join(filter(split(a:attr, ","), "v:val !=? 'italic'"), ",")
    if empty(l:noitalic)
      let l:noitalic = "none"
    endif
    exec "hi ".a:group." gui=".a:attr." cterm=".l:noitalic
  endif
endfun

""""""""""
" Colors "
""""""""""
let g:nightOwl_bg="001526"
let g:white="FFFFFF"
let g:light_grey="637777" " shade2
let g:purple="C792EA" " accent 3

let g:shade0 = "001526"
let g:shade1 = "011627"
let g:shade2 = "637777" "light_grey
let g:shade3 = "C792EA"
let g:shade4 = "ECC48D"
let g:shade5 = "C792EA"
let g:shade6 = "80A4C2"
let g:shade7 = "FDF6E3"
let g:accent0 = "F78C6C"
let g:accent1 = "C792EA"
let g:accent2 = "82AAFF"
let g:accent3 = "C792EA"
let g:accent4 = "ADDB67"
let g:accent5 = "ADDB67"
let g:accent6 = "F78C6C"
let g:accent7 = "FFCB8B"
""""""""""
" Normal "
""""""""""
call s:X("Normal",g:white,g:nightOwl_bg,"","","")

"""""""""""""""""
" Syntax groups "
"""""""""""""""""

" Default

call s:X("Comment",g:light_grey,"","","","")
call s:X("String","ecc48d","","","","")
call s:X("Constant",g:purple,"","","","")
call s:X("Character",g:accent4,"","","","")
call s:X("Identifier","d6deeb","","","","")
call s:X("Statement",g:accent5,"","","","")
call s:X("PreProc","c792ea","","","","")
call s:X("Type",g:accent7,"","","","")
call s:X("Special",g:accent4,"","","","")
call s:X("Underlined",g:accent5,"","","","")
call s:X("Error",g:accent0,g:shade1,"","","")
call s:X("Todo",g:accent0,g:shade1,"","","")
call s:X("Conditional","c792ea","","","","")
call s:X("Repeat","c792ea","","","","")
call s:X("Operator","7fdbca","","","","")
call s:X("Visual","ffffff","4373c2","","","")
call s:X("CursorLine","4b6479","","","","")


" javascript 
hi! link javaScriptValue Constant

call s:X("jsFunction","82AAFF","","","","")
call s:X("jsObjectFuncName","82AAFF","","","","")
call s:X("jsFuncCall","82AAFF","","","","")
call s:X("jsImport","C792EA","","","","")
call s:X("typescriptReserved","C792EA","","italic","","")
call s:X("jsImportContainer","d6deeb","","","","")
call s:X("jsOperator","C792EA","","italic","","")
call s:X("jsStorageClass","82AAFF","","","","")
call s:X("jsFuncArgs","7986E7","","","","")
call s:X("jsBuiltins","82AAFF","","","","")
call s:X("jsString","ECC48D","","","","")
call s:X("jsTemplateString","D3423E","","","","")

" HTML
call s:X("htmlTagName","7fdbca","","","","")
call s:X("jsParen","7fdbca","","","","")
call s:X("htmlSpecialTagName","addb67","","","","")
call s:X("htmlArg","addb67","","italic","","")
call s:X("htmlString","d6deeb","","","","")

" CSS
call s:X("sassDefinition","7fdbca","","","","")
call s:X("sassProperty","7fdbca","","","","")

"""""""""""""""""""""""
" Highlighting Groups "
"""""""""""""""""""""""


" NERDTree

call s:X("NERDTreeHelp","C792EA","","","","")
call s:X("NERDTreeUp","C792EA","","","","")

call s:X("NERDTreeOpenable","ECC48D","","","","")
call s:X("NERDTreeClosable","C792EA","","","","")
call s:X("NERDTreeDir","5F7E97","","","","")
hi! link NERDTreeDirSlash Ignore

""""""""""""
" Clean up "
""""""""""""

" Manual overrides for 256-color terminals. Dark colors auto-map badly.
if !exists("g:nightOwl_bg_256")
  let g:nightOwl_bg_256="NONE"
end

if !s:low_color
  hi StatusLineNC ctermbg=232
  hi Folded ctermbg=236
  hi FoldColumn ctermbg=234
  hi SignColumn ctermbg=236
  hi CursorColumn ctermbg=234
  hi CursorLine ctermbg=235
  hi SpecialKey ctermbg=234
  exec "hi NonText ctermbg=".g:nightOwl_bg_256
  exec "hi LineNr ctermbg=".g:nightOwl_bg_256
  hi DiffText ctermfg=81
  exec "hi Normal ctermbg=".g:nightOwl_bg_256
  hi DbgBreakPt ctermbg=53
  hi IndentGuidesOdd ctermbg=235
  hi IndentGuidesEven ctermbg=234
endif

" delete functions
delf s:X
delf s:rgb
delf s:color
delf s:rgb_color
delf s:rgb_level
delf s:rgb_number
delf s:grey_color
delf s:grey_level
delf s:grey_number
