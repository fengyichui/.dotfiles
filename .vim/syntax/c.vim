" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2019 Apr 23

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:ft = matchstr(&ft, '^\([^.]\)\+')

" Optional embedded Autodoc parsing
" To enable it add: let g:c_autodoc = 1
" to your .vimrc
if exists("c_autodoc")
  syn include @cAutodoc <sfile>:p:h/autodoc.vim
  unlet b:current_syntax
endif

" A bunch of useful C keywords
syn keyword	cStatement	goto break return continue asm
syn keyword	cLabel		case default
syn keyword	cConditional	if else switch
syn keyword	cRepeat		while for do

syn keyword	cTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredictable and should be avoided.
syn match	cBadContinuation contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	cCommentGroup	contains=cTodo,cBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match	cSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syn match	cSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif

if !exists("c_no_cformat")
  " Highlight % items in strings.
  if !exists("c_no_c99") " ISO C99
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syn match	cFormat		display "%%" contained
endif

" cCppString: same as cString, but ends at end of line
if s:ft ==# "cpp" && !exists("cpp_no_cpp11") && !exists("c_no_cformat")
  " ISO C++11
  syn region	cString		start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  syn region 	cCppString	start=+\(L\|u\|u8\|U\|R\|LR\|u8R\|uR\|UR\)\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
elseif s:ft ==# "c" && !exists("c_no_c11") && !exists("c_no_cformat")
  " ISO C99
  syn region	cString		start=+\%(L\|U\|u8\)\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  syn region	cCppString	start=+\%(L\|U\|u8\)\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
else
  " older C or C++
  syn match	cFormat		display "%%" contained
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
endif

syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppSkip

syn cluster	cStringGroup	contains=cCppString,cCppSkip

syn match	cCharacter	"L\='[^\\]'"
syn match	cCharacter	"L'[^']*'" contains=cSpecial
if exists("c_gnu")
  syn match	cSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syn match	cSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syn match	cSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	cSpecialCharacter display "'\\x\x\{1,2}'"
syn match	cSpecialCharacter display "L'\\x\x\+'"

if (s:ft ==# "c" && !exists("c_no_c11")) || (s:ft ==# "cpp" && !exists("cpp_no_cpp11"))
  " ISO C11 or ISO C++ 11
  if exists("c_no_cformat")
    syn region	cString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,@Spell extend
  else
    syn region	cString		start=+\%(U\|u8\=\)"+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell extend
  endif
  syn match	cCharacter	"[Uu]'[^\\]'"
  syn match	cCharacter	"[Uu]'[^']*'" contains=cSpecial
  if exists("c_gnu")
    syn match	cSpecialError	"[Uu]'\\[^'\"?\\abefnrtv]'"
    syn match	cSpecialCharacter "[Uu]'\\['\"?\\abefnrtv]'"
  else
    syn match	cSpecialError	"[Uu]'\\[^'\"?\\abfnrtv]'"
    syn match	cSpecialCharacter "[Uu]'\\['\"?\\abfnrtv]'"
  endif
  syn match	cSpecialCharacter display "[Uu]'\\\o\{1,3}'"
  syn match	cSpecialCharacter display "[Uu]'\\x\x\+'"
endif

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syn match	cSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syn match	cSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syn match cCurlyError "}"
  syn region	cBlock		start="{" end="}" contains=ALLBUT,cBadBlock,cCurlyError,@cParenGroup,cErrInParen,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell fold
else
  syn region	cBlock		start="{" end="}" transparent fold
endif

" Catch errors caused by wrong parenthesis and brackets.
" Also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syn cluster	cParenGroup	contains=cParenError,cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserLabel,cBitField,cOctalZero,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom
if exists("c_no_curly_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "^^<%\|^%>"
  else
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,cBlock,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "^[{}]\|^<%\|^%>"
  endif
elseif exists("c_no_bracket_error")
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "<%\|%>"
  else
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
    syn match	cParenError	display ")"
    syn match	cErrInParen	display contained "[{}]\|<%\|%>"
  endif
else
  if s:ft ==# 'cpp' && !exists("cpp_no_cpp11")
    syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
    syn match	cParenError	display "[\])]"
    syn match	cErrInParen	display contained "<%\|%>"
    syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@cParenGroup,cErrInParen,cCppParen,cCppBracket,@cStringGroup,@Spell
  else
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,@cStringGroup,@Spell
    " cCppParen: same as cParen but ends at end-of-line; used in cDefine
    syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
    syn match	cParenError	display "[\])]"
    syn match	cErrInParen	display contained "[\]{}]\|<%\|%>"
    syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cErrInParen,cCppParen,cCppBracket,@cStringGroup,@Spell
  endif
  " cCppBracket: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@cParenGroup,cErrInParen,cParen,cBracket,cString,@Spell
  syn match	cErrInBracket	display contained "[);{}]\|<%\|%>"
endif

if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	cBadBlock	keepend start="{" end="}" contained containedin=cParen,cBracket,cBadBlock transparent fold
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	cNumbers	display transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctalError,cOctal
" Same, but without octal error (for comments)
syn match	cNumbersCom	display contained transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctal
syn match	cNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	cNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	cOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=cOctalZero
syn match	cOctalZero	display contained "\<0"
syn match	cFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	cFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	cFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	cFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	cFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	cFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	cOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain cString, cCharacter and cNumber.
  " But a "*/" inside a cString in a cComment DOES end the comment!  So we
  " need to use a special type of cString: cCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syn match	cCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syn region cCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,cCommentSkip
  syn region cComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syn region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,cWrongComTail,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syn region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell extend
  else
    syn region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell fold extend
  endif
else
  syn region	cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell extend
  else
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syn match	cCommentError	display "\*/"
syn match	cCommentStartError display "/\*"me=e-1 contained
syn match	cWrongComTail	display "\*/"

syn keyword	cOperator	sizeof
if exists("c_gnu")
  syn keyword	cStatement	__asm__
  syn keyword	cOperator	typeof __real__ __imag__
endif
syn keyword	cType		int long short char void
syn keyword	cType		signed unsigned float double
if !exists("c_no_ansi") || exists("c_ansi_typedefs")
  syn keyword   cType		size_t ssize_t off_t wchar_t ptrdiff_t sig_atomic_t fpos_t
  syn keyword   cType		clock_t time_t va_list jmp_buf FILE DIR div_t ldiv_t
  syn keyword   cType		mbstate_t wctrans_t wint_t wctype_t
endif
if !exists("c_no_c99") " ISO C99
  syn keyword	cType		_Bool bool _Complex complex _Imaginary imaginary
  syn keyword	cType		int8_t int16_t int32_t int64_t
  syn keyword	cType		uint8_t uint16_t uint32_t uint64_t
  if !exists("c_no_bsd")
    " These are BSD specific.
    syn keyword	cType		u_int8_t u_int16_t u_int32_t u_int64_t
  endif
  syn keyword	cType		int_least8_t int_least16_t int_least32_t int_least64_t
  syn keyword	cType		uint_least8_t uint_least16_t uint_least32_t uint_least64_t
  syn keyword	cType		int_fast8_t int_fast16_t int_fast32_t int_fast64_t
  syn keyword	cType		uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
  syn keyword	cType		intptr_t uintptr_t
  syn keyword	cType		intmax_t uintmax_t
endif
if exists("c_gnu")
  syn keyword	cType		__label__ __complex__ __volatile__
endif

syn keyword	cStructure	struct union enum typedef
syn keyword	cStorageClass	static register auto volatile extern const
if exists("c_gnu")
  syn keyword	cStorageClass	inline __attribute__
endif
if !exists("c_no_c99") && s:ft !=# 'cpp'
  syn keyword	cStorageClass	inline restrict
endif
if !exists("c_no_c11")
  syn keyword	cStorageClass	_Alignas alignas
  syn keyword	cOperator	_Alignof alignof
  syn keyword	cStorageClass	_Atomic
  syn keyword	cOperator	_Generic
  syn keyword	cStorageClass	_Noreturn noreturn
  syn keyword	cOperator	_Static_assert static_assert
  syn keyword	cStorageClass	_Thread_local thread_local
  syn keyword   cType		char16_t char32_t
  " C11 atomics (take down the shield wall!)
  syn keyword	cType		atomic_bool atomic_char atomic_schar atomic_uchar
  syn keyword	Ctype		atomic_short atomic_ushort atomic_int atomic_uint
  syn keyword	cType		atomic_long atomic_ulong atomic_llong atomic_ullong
  syn keyword	cType		atomic_char16_t atomic_char32_t atomic_wchar_t
  syn keyword	cType		atomic_int_least8_t atomic_uint_least8_t
  syn keyword	cType		atomic_int_least16_t atomic_uint_least16_t
  syn keyword	cType		atomic_int_least32_t atomic_uint_least32_t
  syn keyword	cType		atomic_int_least64_t atomic_uint_least64_t
  syn keyword	cType		atomic_int_fast8_t atomic_uint_fast8_t
  syn keyword	cType		atomic_int_fast16_t atomic_uint_fast16_t
  syn keyword	cType		atomic_int_fast32_t atomic_uint_fast32_t
  syn keyword	cType		atomic_int_fast64_t atomic_uint_fast64_t
  syn keyword	cType		atomic_intptr_t atomic_uintptr_t
  syn keyword	cType		atomic_size_t atomic_ptrdiff_t
  syn keyword	cType		atomic_intmax_t atomic_uintmax_t
endif

if !exists("c_no_ansi") || exists("c_ansi_constants") || exists("c_gnu")
  if exists("c_gnu")
    syn keyword cConstant __GNUC__ __FUNCTION__ __PRETTY_FUNCTION__ __func__
  endif
  syn keyword cConstant __LINE__ __FILE__ __DATE__ __TIME__ __STDC__
  syn keyword cConstant __STDC_VERSION__
  syn keyword cConstant CHAR_BIT MB_LEN_MAX MB_CUR_MAX
  syn keyword cConstant UCHAR_MAX UINT_MAX ULONG_MAX USHRT_MAX
  syn keyword cConstant CHAR_MIN INT_MIN LONG_MIN SHRT_MIN
  syn keyword cConstant CHAR_MAX INT_MAX LONG_MAX SHRT_MAX
  syn keyword cConstant SCHAR_MIN SINT_MIN SLONG_MIN SSHRT_MIN
  syn keyword cConstant SCHAR_MAX SINT_MAX SLONG_MAX SSHRT_MAX
  if !exists("c_no_c99")
    syn keyword cConstant __func__ __VA_ARGS__
    syn keyword cConstant LLONG_MIN LLONG_MAX ULLONG_MAX
    syn keyword cConstant INT8_MIN INT16_MIN INT32_MIN INT64_MIN
    syn keyword cConstant INT8_MAX INT16_MAX INT32_MAX INT64_MAX
    syn keyword cConstant UINT8_MAX UINT16_MAX UINT32_MAX UINT64_MAX
    syn keyword cConstant INT_LEAST8_MIN INT_LEAST16_MIN INT_LEAST32_MIN INT_LEAST64_MIN
    syn keyword cConstant INT_LEAST8_MAX INT_LEAST16_MAX INT_LEAST32_MAX INT_LEAST64_MAX
    syn keyword cConstant UINT_LEAST8_MAX UINT_LEAST16_MAX UINT_LEAST32_MAX UINT_LEAST64_MAX
    syn keyword cConstant INT_FAST8_MIN INT_FAST16_MIN INT_FAST32_MIN INT_FAST64_MIN
    syn keyword cConstant INT_FAST8_MAX INT_FAST16_MAX INT_FAST32_MAX INT_FAST64_MAX
    syn keyword cConstant UINT_FAST8_MAX UINT_FAST16_MAX UINT_FAST32_MAX UINT_FAST64_MAX
    syn keyword cConstant INTPTR_MIN INTPTR_MAX UINTPTR_MAX
    syn keyword cConstant INTMAX_MIN INTMAX_MAX UINTMAX_MAX
    syn keyword cConstant PTRDIFF_MIN PTRDIFF_MAX SIG_ATOMIC_MIN SIG_ATOMIC_MAX
    syn keyword cConstant SIZE_MAX WCHAR_MIN WCHAR_MAX WINT_MIN WINT_MAX
  endif
  syn keyword cConstant FLT_RADIX FLT_ROUNDS FLT_DIG FLT_MANT_DIG FLT_EPSILON DBL_DIG DBL_MANT_DIG DBL_EPSILON
  syn keyword cConstant LDBL_DIG LDBL_MANT_DIG LDBL_EPSILON FLT_MIN FLT_MAX FLT_MIN_EXP FLT_MAX_EXP FLT_MIN_10_EXP FLT_MAX_10_EXP
  syn keyword cConstant DBL_MIN DBL_MAX DBL_MIN_EXP DBL_MAX_EXP DBL_MIN_10_EXP DBL_MAX_10_EXP LDBL_MIN LDBL_MAX LDBL_MIN_EXP LDBL_MAX_EXP
  syn keyword cConstant LDBL_MIN_10_EXP LDBL_MAX_10_EXP HUGE_VAL CLOCKS_PER_SEC NULL LC_ALL LC_COLLATE LC_CTYPE LC_MONETARY
  syn keyword cConstant LC_NUMERIC LC_TIME SIG_DFL SIG_ERR SIG_IGN SIGABRT SIGFPE SIGILL SIGHUP SIGINT SIGSEGV SIGTERM
  " Add POSIX signals as well...
  syn keyword cConstant SIGABRT SIGALRM SIGCHLD SIGCONT SIGFPE SIGHUP SIGILL SIGINT SIGKILL SIGPIPE SIGQUIT SIGSEGV
  syn keyword cConstant SIGSTOP SIGTERM SIGTRAP SIGTSTP SIGTTIN SIGTTOU SIGUSR1 SIGUSR2
  syn keyword cConstant _IOFBF _IOLBF _IONBF BUFSIZ EOF WEOF FOPEN_MAX FILENAME_MAX L_tmpnam
  syn keyword cConstant SEEK_CUR SEEK_END SEEK_SET TMP_MAX stderr stdin stdout EXIT_FAILURE EXIT_SUCCESS RAND_MAX
  " POSIX 2001
  syn keyword cConstant SIGBUS SIGPOLL SIGPROF SIGSYS SIGURG SIGVTALRM SIGXCPU SIGXFSZ
  " non-POSIX signals
  syn keyword cConstant SIGWINCH SIGINFO
  " Add POSIX errors as well.  List comes from:
  " http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/errno.h.html
  " liqiang<> (more errors)
  syn keyword cConstant EPERM ENOMEM ENFILE ERANGE EDEADLK ENODATA EMULTIHOP ELIBMAX EAFNOSUPPORT EHOSTDOWN ENOTCONN EOVERFLOW
  syn keyword cConstant ENOENT EACCES EMFILE ENOMSG ENOLCK ETIME ELBIN ELIBEXEC EPROTOTYPE EHOSTUNREACH ETOOMANYREFS ECANCELED
  syn keyword cConstant ESRCH EFAULT ENOTTY EIDRM EBADE ENOSR EDOTDOT ENOSYS ENOTSOCK EINPROGRESS EPROCLIM ENOTRECOVERABLE
  syn keyword cConstant EINTR ENOTBLK ETXTBSY ECHRNG EBADR ENONET EBADMSG ENMFILE ENOPROTOOPT EALREADY EUSERS EOWNERDEAD
  syn keyword cConstant EIO EBUSY EFBIG EL2NSYNC EXFULL ENOPKG EFTYPE ENOTEMPTY ESHUTDOWN EDESTADDRREQ EDQUOT ESTRPIPE
  syn keyword cConstant ENXIO EEXIST ENOSPC EL3HLT ENOANO EREMOTE ENOTUNIQ ENAMETOOLONG ECONNREFUSED EMSGSIZE ESTALE EWOULDBLOCK
  syn keyword cConstant E2BIG EXDEV ESPIPE EL3RST EBADRQC ENOLINK EBADFD ELOOP EADDRINUSE EPROTONOSUPPORT ENOTSUP __ELASTERROR
  syn keyword cConstant ENOEXEC ENODEV EROFS ELNRNG EBADSLT EADV EREMCHG EOPNOTSUPP ECONNABORTED ESOCKTNOSUPPORT ENOMEDIUM
  syn keyword cConstant EBADF ENOTDIR EMLINK EUNATCH EDEADLOCK ESRMNT ELIBACC EPFNOSUPPORT ENETUNREACH EADDRNOTAVAIL ENOSHARE
  syn keyword cConstant ECHILD EISDIR EPIPE ENOCSI EBFONT ECOMM ELIBBAD ECONNRESET ENETDOWN ENETRESET ECASECLASH
  syn keyword cConstant EAGAIN EINVAL EDOM EL2HLT ENOSTR EPROTO ELIBSCN ENOBUFS ETIMEDOUT EISCONN EILSEQ
  syn keyword cConstant ERESTART EUCLEAN ENOTNAM ENAVAIL EISNAM EREMOTEIO EMEDIUMTYPE ENOKEY EKEYEXPIRED EKEYREVOKED EKEYREJECTED ERFKILL EHWPOISON
  " math.h
  syn keyword cConstant M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4
  syn keyword cConstant M_1_PI M_2_PI M_2_SQRTPI M_SQRT2 M_SQRT1_2
endif
if !exists("c_no_c99") " ISO C99
  syn keyword cConstant true false
endif

" Accept %: for # (C99)
syn region	cPreCondit	start="^\s*\zs\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" keepend contains=cComment,cCommentL,cCppString,cCharacter,cCppParen,cParenError,cNumbers,cCommentError,cSpaceError
syn match	cPreConditMatch	display "^\s*\zs\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  syn cluster	cCppOutInGroup	contains=cCppInIf,cCppInElse,cCppInElse2,cCppOutIf,cCppOutIf2,cCppOutElse,cCppInSkip,cCppOutSkip
  syn region	cCppOutWrapper	start="^\s*\zs\(%:\|#\)\s*if\s\+0\+\s*\($\|//\|/\*\|&\)" end=".\@=\|$" contains=cCppOutIf,cCppOutElse,@NoSpell fold
  syn region	cCppOutIf	contained start="0\+" matchgroup=cCppOutWrapper end="^\s*\(%:\|#\)\s*endif\>" contains=cCppOutIf2,cCppOutElse
  if !exists("c_no_if0_fold")
    syn region	cCppOutIf2	contained matchgroup=cCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell fold
  else
    syn region	cCppOutIf2	contained matchgroup=cCppOutWrapper start="0\+" end="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0\+\s*\($\|//\|/\*\|&\)\)\@!\|endif\>\)"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell
  endif
  syn region	cCppOutElse	contained matchgroup=cCppOutWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=TOP,cPreCondit
  syn region	cCppInWrapper	start="^\s*\zs\(%:\|#\)\s*if\s\+0*[1-9]\d*\s*\($\|//\|/\*\||\)" end=".\@=\|$" contains=cCppInIf,cCppInElse fold
  syn region	cCppInIf	contained matchgroup=cCppInWrapper start="\d\+" end="^\s*\(%:\|#\)\s*endif\>" contains=TOP,cPreCondit
  if !exists("c_no_if0_fold")
    syn region	cCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=cCppInIf contains=cCppInElse2 fold
  else
    syn region	cCppInElse	contained start="^\s*\(%:\|#\)\s*\(else\>\|elif\s\+\(0*[1-9]\d*\s*\($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=cCppInIf contains=cCppInElse2
  endif
  syn region	cCppInElse2	contained matchgroup=cCppInWrapper start="^\s*\(%:\|#\)\s*\(else\|elif\)\([^/]\|/[^/*]\)*" end="^\s*\(%:\|#\)\s*endif\>"me=s-1 contains=cSpaceError,cCppOutSkip,@Spell
  syn region	cCppOutSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppOutSkip
  syn region	cCppInSkip	contained matchgroup=cCppInWrapper start="^\s*\(%:\|#\)\s*\(if\s\+\(\d\+\s*\($\|//\|/\*\||\|&\)\)\@!\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" containedin=cCppOutElse,cCppInIf,cCppInSkip contains=TOP,cPreProc
endif
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\zs\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
"syn match cLineSkip	"\\$"
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cErrInParen,cErrInBracket,cUserLabel,cSpecial,cOctalZero,cCppOutWrapper,cCppInWrapper,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cString,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cParen,cBracket,cMulti,cBadBlock
syn region	cDefine		start="^\s*\zs\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
syn region	cPreProc	start="^\s*\zs\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell

" Optional embedded Autodoc parsing
if exists("c_autodoc")
  syn match cAutodocReal display contained "\%(//\|[/ \t\v]\*\|^\*\)\@2<=!.*" contains=@cAutodoc containedin=cComment,cCommentL
  syn cluster cCommentGroup add=cAutodocReal
  syn cluster cPreProcGroup add=cAutodocReal
endif

" Highlight User Labels
syn cluster	cMultiGroup	contains=cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOutWrapper,cCppInWrapper,@cCppOutInGroup,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cCppParen,cCppBracket,cCppString
if s:ft ==# 'c' || exists("cpp_no_cpp11")
  syn region	cMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@cMultiGroup,@Spell,@cStringGroup
endif
" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	cLabelGroup	contains=cUserLabel
syn match	cUserCont	display "^\s*\zs\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display ";\s*\zs\I\i*\s*:$" contains=@cLabelGroup
if s:ft ==# 'cpp'
  syn match	cUserCont	display "^\s*\zs\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
  syn match	cUserCont	display ";\s*\zs\%(class\|struct\|enum\)\@!\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
else
  syn match	cUserCont	display "^\s*\zs\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
  syn match	cUserCont	display ";\s*\zs\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
endif

syn match	cUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	cBitField	display "^\s*\zs\I\i*\s*:\s*[1-9]"me=e-1 contains=cType
syn match	cBitField	display ";\s*\zs\I\i*\s*:\s*[1-9]"me=e-1 contains=cType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

"add by liqiang
syn keyword cFunction  abs gmtime putchar_unlocked srand vfprintf bsd_signal fopen iswpunct sigdelset wcrtomb getpid rmdir fseeko strspn
syn keyword cFunction  dup mbsnrtowcs setlinebuf strtoumax wcstoll execvp getenv mktemp strcspn wmemcmp ldiv strndup getsubopt ttyslot
syn keyword cFunction  fexecve putc sleep vasprintf bcmp fileno_unlocked iswgraph random timegm feenableexcept open_wmemstream tolower longjmp wcsncmp
syn keyword cFunction  ftrylockfile sethostname strtoq wcstok execlp getdomainname mkostemps sigaltstack vwscanf fputwc_unlocked revoke wcscpy popen dprintf
syn keyword cFunction  getwchar sigvec uselocale atol fgetws iswcntrl quick_exit strcmp wctype getpass sigisemptyset wscanf seed48 fetestexcept
syn keyword cFunction  mbrlen strtol wcstod euidaccess getcwd memset setvbuf tcgetpgrp clearenv labs strncat feof_unlocked sigprocmask ftello
syn keyword cFunction  psiginfo unlinkat atexit fgets_unlocked iswalnum qfcvt strcat vswprintf fdopen obstack_vprintf tmpfile freopen strrchr getwc
syn keyword cFunction  seteuid wcsrtombs encrypt getc_unlocked memmove setstate sysconf wctob fputs sighold wcschrnul getresuid towupper matherr
syn keyword cFunction  sigstack asctime fgetc_unlocked isascii putwchar_unlocked stpncpy vsnprintf chdir getloadavg strftime wmemset localeconv wcslen printf
syn keyword cFunction  strtof dysize gcvt memcpy setresuid symlink wcswcs fcloseall jrand48 timer_getoverrun clock_nanosleep perror daemon setegid
syn keyword cFunction  ungetc ffsl imaxabs putwc ssignal vhangup calloc fprintf newlocale wcscasecmp fegetround rpmatch fesetenv sigset
syn keyword cFunction  wcsnrtombs fwrite memccpy setpgrp swab wcstoull fchown gethostid readlinkat wmemcpy fread_unlocked sigorset fsetpos strstr
syn keyword cFunction  dup2 grantpt putenv srand48 vfscanf bsearch fopencookie iswspace sigemptyset clock_getcpuclockid getppid strnlen getuid tzset
syn keyword cFunction  fflush mbsrtowcs setlocale strtouq wcstombs execvpe geteuid mktime strdup fegetenv linkat toupper lrand48 wcsncpy
syn keyword cFunction  funlockfile putc_unlocked snprintf vdprintf bcopy flockfile iswlower rawmemchr timelocal fputws pathconf wcscspn posix_memalign drand48
syn keyword cFunction  getwchar_unlocked setjmp strtoul wcstol execv getdtablesize mkstemp sigandset wcpcpy getpgid rewind ctermid setbuf feupdateenv
syn keyword cFunction  mbrtowc sigwait usleep atoll fgetws_unlocked iswctype raise strcoll wcwidth lchown sigismember feraiseexcept sigqueue ftruncate
syn keyword cFunction  psignal strtold wcstof execl getdate mkdtemp sigaction tcsetpgrp clearerr on_exit strncmp fscanf strsep getwc_unlocked
syn keyword cFunction  setgid unlockpt atof fgetwc iswalpha qgcvt strchr vswscanf feclearexcept sigignore tmpnam gets truncate mblen
syn keyword cFunction  sigsuspend wcsspn endusershell getchar mempcpy setuid system wctomb fputs_unlocked strlen wcscmp localtime wcsncasecmp profil
syn keyword cFunction  strtoimax asprintf fgetpos isatty pwrite strcasecmp vsprintf chown getlogin timer_gettime wprintf sbrk difftime setenv
syn keyword cFunction  ungetwc eaccess get_current_dir_name memfrob setreuid symlinkat wcswidth fcvt nrand48 wcscat clock_settime sigpause fesetexceptflag sigsetmask
syn keyword cFunction  wcspbrk ffsll imaxdiv putwc_unlocked stime vprintf canonicalize_file_name fputc realloc wmemmove feholdexcept strpbrk fsync strtod
syn keyword cFunction  acct fwrite_unlocked memchr setregid swprintf wcstoumax fchownat gethostname sigfillset clock_getres free towctrans getusershell ualarm
syn keyword cFunction  dup3 group_member puts srandom vfwprintf btowc fork iswupper strerror fegetexcept getpt wcsdup lseek wcsnlen
syn keyword cFunction  fflush_unlocked mbstowcs setlogin strverscmp wcstoq faccessat getgid mrand48 timer_create fputws_unlocked llabs ctime
syn keyword cFunction  posix_openpt fwide putchar sprintf vfork brk fmemopen iswprint sigblock wcpncpy getpgrp pause ferror setbuffer
syn keyword cFunction  getwd setkey strtoull wcstold execve getegid mkstemps strcpy wmemchr lcong48 rindex fseek sigrelse
syn keyword cFunction  mbsinit sigwaitinfo valloc basename fileno iswdigit rand tempnam clearerr_unlocked open_memstream siglongjmp getsid strsignal
syn keyword cFunction  ptsname strtoll wcstoimax execle getdelim mkostemp sigaddset vwprintf fedisableexcept renameat strncpy lockf ttyname
syn keyword cFunction  sethostid unsetenv atoi fgetwc_unlocked iswblank qsort strchrnul wctrans fputwc siginterrupt toascii pipe2 wcsncat
syn keyword cFunction  sigtimedwait wcsstr erand48 getchar_unlocked memrchr setusershell sysv_signal chroot getpagesize strncasecmp wcscoll scanf fesetround
syn keyword cFunction  strtok at_quick_exit fgets isctype qecvt strcasestr vsscanf fdatasync killpg timer_settime confstr sigpending ftell
syn keyword cFunction  wcsrchr ecvt getc memmem setsid syscall wcsxfrm fputc_unlocked obstack_printf wcschr feof strptime getw
syn keyword cFunction  alarm fgetc initstate putwchar stpcpy vscanf cfree getline realpath wmempcpy freelocale towlower malloc
syn keyword cFunction  duplocale fwscanf memcmp setresgid swscanf wcstouq fclose iswxdigit siggetmask clock_gettime getresgid wcsftime pread
syn keyword cFunction  ffs gsignal putw sscanf vfwscanf bzero fpathconf nanosleep strfry fegetexceptflag lldiv cuserid setdomainname
syn keyword cFunction  fwprintf mbtowc setpgid strxfrm wcstoul fchdir getgroups readlink timer_delete fread pclose ferror_unlocked sigreturn
syn keyword cFunction  va_start va_end

" syn keyword cCPPType   auto_ptr binder1st divides hash_multimap istreambuf_iterator ostream_iterator random_access_iterator temporary_buffer
" syn keyword cCPPType   back_insert_iterator binder2nd equal_to hash_multiset istringstream ostringstream random_access_iterator_tag unary_compose
" syn keyword cCPPType   basic_string bit_vector filebuf hash_set iterator output_iterator raw_storage_iterator unary_function
" syn keyword cCPPType   bidirectional_iterator bitset forward_iterator ifstream iterator_traits output_iterator_tag reverse_bidirectional_iterator unary_negate
" syn keyword cCPPType   bidirectional_iterator_tag char_producer forward_iterator_tag input_iterator multimap pointer reverse_iterator vector
" syn keyword cCPPType   binary_compose char_traits front_insert_iterator input_iterator_tag multiset pointer_to_binary_function rope
" syn keyword cCPPType   binary_function const_iterator fstream insert_iterator ofstream pointer_to_unary_function sequence_buffer
" syn keyword cCPPType   binary_negate deque hash_map istream_iterator ostream priority_queue stream

hi def link cFunction  Function
" hi def link cCPPType   Type

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cFormat		cSpecial
hi def link cCppString		cString
hi def link cCommentL		cComment
hi def link cCommentStart	cComment
hi def link cLabel		Label
hi def link cUserLabel		Label
hi def link cConditional	Conditional
hi def link cRepeat		Repeat
hi def link cCharacter		Character
hi def link cSpecialCharacter	cSpecial
hi def link cNumber		Number
hi def link cOctal		Number
hi def link cOctalZero		PreProc	 " link this to Error if you want
hi def link cFloat		Float
hi def link cOctalError		cError
hi def link cParenError		cError
hi def link cErrInParen		cError
hi def link cErrInBracket	cError
hi def link cCommentError	cError
hi def link cCommentStartError	cError
hi def link cSpaceError		cError
hi def link cWrongComTail	cError
hi def link cSpecialError	cError
hi def link cCurlyError		cError
hi def link cOperator		Operator
hi def link cStructure		Structure
hi def link cStorageClass	StorageClass
hi def link cInclude		Include
hi def link cPreProc		PreProc
hi def link cDefine		Macro
hi def link cIncluded		cString
hi def link cError		Error
hi def link cStatement		Statement
hi def link cCppInWrapper	cCppOutWrapper
hi def link cCppOutWrapper	cPreCondit
hi def link cPreConditMatch	cPreCondit
hi def link cPreCondit		PreCondit
hi def link cType		Type
hi def link cConstant		Constant
hi def link cCommentString	cString
hi def link cComment2String	cString
hi def link cCommentSkip	cComment
hi def link cString		String
hi def link cComment		Comment
hi def link cSpecial		SpecialChar
hi def link cTodo		Todo
hi def link cBadContinuation	Error
hi def link cCppOutSkip		cCppOutIf2
hi def link cCppInElse2		cCppOutIf2
hi def link cCppOutIf2		cCppOut
hi def link cCppOut		Comment

let b:current_syntax = "c"

unlet s:ft

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: ts=8
