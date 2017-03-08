" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2016 Nov 18

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:ft = matchstr(&ft, '^\([^.]\)\+')

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
    syn region	cParen		transparent start='(' end=')' end='}'me=s-1 contains=ALLBUT,cBlock,@cParenGroup,cCppParen,@cStringGroup,@Spell
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
  syn region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,@Spell
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
  syn keyword cConstant FLT_RADIX FLT_ROUNDS
  syn keyword cConstant FLT_DIG FLT_MANT_DIG FLT_EPSILON
  syn keyword cConstant DBL_DIG DBL_MANT_DIG DBL_EPSILON
  syn keyword cConstant LDBL_DIG LDBL_MANT_DIG LDBL_EPSILON
  syn keyword cConstant FLT_MIN FLT_MAX FLT_MIN_EXP FLT_MAX_EXP
  syn keyword cConstant FLT_MIN_10_EXP FLT_MAX_10_EXP
  syn keyword cConstant DBL_MIN DBL_MAX DBL_MIN_EXP DBL_MAX_EXP
  syn keyword cConstant DBL_MIN_10_EXP DBL_MAX_10_EXP
  syn keyword cConstant LDBL_MIN LDBL_MAX LDBL_MIN_EXP LDBL_MAX_EXP
  syn keyword cConstant LDBL_MIN_10_EXP LDBL_MAX_10_EXP
  syn keyword cConstant HUGE_VAL CLOCKS_PER_SEC NULL
  syn keyword cConstant LC_ALL LC_COLLATE LC_CTYPE LC_MONETARY
  syn keyword cConstant LC_NUMERIC LC_TIME
  syn keyword cConstant SIG_DFL SIG_ERR SIG_IGN
  syn keyword cConstant SIGABRT SIGFPE SIGILL SIGHUP SIGINT SIGSEGV SIGTERM
  " Add POSIX signals as well...
  syn keyword cConstant SIGABRT SIGALRM SIGCHLD SIGCONT SIGFPE SIGHUP
  syn keyword cConstant SIGILL SIGINT SIGKILL SIGPIPE SIGQUIT SIGSEGV
  syn keyword cConstant SIGSTOP SIGTERM SIGTRAP SIGTSTP SIGTTIN SIGTTOU
  syn keyword cConstant SIGUSR1 SIGUSR2
  syn keyword cConstant _IOFBF _IOLBF _IONBF BUFSIZ EOF WEOF
  syn keyword cConstant FOPEN_MAX FILENAME_MAX L_tmpnam
  syn keyword cConstant SEEK_CUR SEEK_END SEEK_SET
  syn keyword cConstant TMP_MAX stderr stdin stdout
  syn keyword cConstant EXIT_FAILURE EXIT_SUCCESS RAND_MAX
  " POSIX 2001
  syn keyword cConstant SIGBUS SIGPOLL SIGPROF SIGSYS SIGURG
  syn keyword cConstant SIGVTALRM SIGXCPU SIGXFSZ
  " non-POSIX signals
  syn keyword cConstant SIGWINCH SIGINFO
  " Add POSIX errors as well
  syn keyword cConstant E2BIG EACCES EAGAIN EBADF EBADMSG EBUSY
  syn keyword cConstant ECANCELED ECHILD EDEADLK EDOM EEXIST EFAULT
  syn keyword cConstant EFBIG EILSEQ EINPROGRESS EINTR EINVAL EIO EISDIR
  syn keyword cConstant EMFILE EMLINK EMSGSIZE ENAMETOOLONG ENFILE ENODEV
  syn keyword cConstant ENOENT ENOEXEC ENOLCK ENOMEM ENOSPC ENOSYS
  syn keyword cConstant ENOTDIR ENOTEMPTY ENOTSUP ENOTTY ENXIO EPERM
  syn keyword cConstant EPIPE ERANGE EROFS ESPIPE ESRCH ETIMEDOUT EXDEV
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
syn keyword   cFunction         tolower toupper isctype isascii toascii tolower_l toupper_l setlocale localeconv newlocale duplocale freelocale uselocale matherr setjmp _setjmp longjmp _longjmp siglongjmp sysv_signal signal bsd_signal kill killpg raise ssignal gsignal psignal psiginfo sigpause sigblock sigsetmask siggetmask sigemptyset sigfillset sigaddset sigdelset sigismember sigisemptyset sigandset sigorset sigprocmask sigsuspend sigaction sigpending sigwait sigwaitinfo sigtimedwait sigqueue sigvec sigreturn siginterrupt sigstack sigaltstack sighold sigrelse sigignore sigset remove rename renameat tmpfile tmpfile64 tmpnam tmpnam_r tempnam fclose fflush fflush_unlocked fcloseall fopen freopen fopen64 freopen64 fdopen fopencookie fmemopen open_memstream setbuf setvbuf setbuffer setlinebuf fprintf printf sprintf vfprintf vprintf vsprintf snprintf vsnprintf vasprintf asprintf vdprintf dprintf fscanf scanf sscanf vfscanf vscanf vsscanf fgetc getc getchar getc_unlocked getchar_unlocked fgetc_unlocked fputc putc putchar fputc_unlocked putc_unlocked putchar_unlocked getw putw fgets gets fgets_unlocked getdelim getline fputs puts ungetc fread fwrite fputs_unlocked fread_unlocked fwrite_unlocked fseek ftell rewind fseeko ftello fgetpos fsetpos fseeko64 ftello64 fgetpos64 fsetpos64 clearerr feof ferror clearerr_unlocked feof_unlocked ferror_unlocked perror fileno fileno_unlocked popen pclose ctermid cuserid obstack_printf obstack_vprintf flockfile ftrylockfile funlockfile memcpy memmove memccpy memset memcmp memchr rawmemchr memrchr strcpy strncpy strcat strncat strcmp strncmp strcoll strxfrm strcoll_l strxfrm_l strdup strndup strchr strrchr strchrnul strcspn strspn strpbrk strstr strtok strtok_r strcasestr memmem mempcpy strlen strnlen strerror strerror_r strerror_l bcopy bzero bcmp rindex ffs ffsl ffsll strcasecmp strncasecmp strcasecmp_l strncasecmp_l strsep strsignal stpcpy stpncpy strverscmp strfry memfrob basename atof atoi atol atoll strtod strtof strtold strtol strtoul strtoq strtouq strtoll strtoull strtol_l strtoul_l strtoll_l strtoull_l strtod_l strtof_l strtold_l l64a a64l random srandom initstate setstate random_r srandom_r initstate_r setstate_r rand srand rand_r drand48 erand48 lrand48 nrand48 mrand48 jrand48 srand48 seed48 lcong48 drand48_r erand48_r lrand48_r nrand48_r mrand48_r jrand48_r srand48_r seed48_r lcong48_r malloc calloc realloc free cfree valloc posix_memalign abort atexit at_quick_exit on_exit exit quick_exit _Exit getenv putenv setenv unsetenv clearenv mktemp mkstemp mkstemp64 mkstemps mkstemps64 mkdtemp mkostemp mkostemp64 mkostemps mkostemps64 system canonicalize_file_name realpath bsearch qsort qsort_r abs labs llabs div ldiv lldiv ecvt fcvt gcvt qecvt qfcvt qgcvt ecvt_r fcvt_r qecvt_r qfcvt_r mblen mbtowc wctomb mbstowcs wcstombs rpmatch getsubopt setkey posix_openpt grantpt unlockpt ptsname ptsname_r getpt getloadavg clock time difftime mktime strftime strptime strftime_l strptime_l gmtime localtime gmtime_r localtime_r asctime ctime asctime_r ctime_r tzset stime timegm timelocal dysize nanosleep clock_getres clock_gettime clock_settime clock_nanosleep clock_getcpuclockid timer_create timer_delete timer_settime timer_gettime timer_getoverrun getdate getdate_r feclearexcept fegetexceptflag feraiseexcept fesetexceptflag fetestexcept fegetround fesetround fegetenv feholdexcept fesetenv feupdateenv feenableexcept fedisableexcept fegetexcept imaxabs imaxdiv strtoimax strtoumax wcstoimax wcstoumax wcscpy wcsncpy wcscat wcsncat wcscmp wcsncmp wcscasecmp wcsncasecmp wcscasecmp_l wcsncasecmp_l wcscoll wcsxfrm wcscoll_l wcsxfrm_l wcsdup wcschr wcsrchr wcschrnul wcscspn wcsspn wcspbrk wcsstr wcstok wcslen wcswcs wcsnlen wmemchr wmemcmp wmemcpy wmemmove wmemset wmempcpy btowc wctob mbsinit mbrtowc wcrtomb mbrlen mbsrtowcs wcsrtombs mbsnrtowcs wcsnrtombs wcwidth wcswidth wcstod wcstof wcstold wcstol wcstoul wcstoll wcstoull wcstoq wcstouq wcstol_l wcstoul_l wcstoll_l wcstoull_l wcstod_l wcstof_l wcstold_l wcpcpy wcpncpy open_wmemstream fwide fwprintf wprintf swprintf vfwprintf vwprintf vswprintf fwscanf wscanf swscanf vfwscanf vwscanf vswscanf fgetwc getwc getwchar fputwc putwc putwchar fgetws fputws ungetwc getwc_unlocked getwchar_unlocked fgetwc_unlocked fputwc_unlocked putwc_unlocked putwchar_unlocked fgetws_unlocked fputws_unlocked wcsftime wcsftime_l iswalnum iswalpha iswcntrl iswdigit iswgraph iswlower iswprint iswpunct iswspace iswupper iswxdigit iswblank wctype iswctype towlower towupper wctrans towctrans iswalnum_l iswalpha_l iswcntrl_l iswdigit_l iswgraph_l iswlower_l iswprint_l iswpunct_l iswspace_l iswupper_l iswxdigit_l iswblank_l wctype_l iswctype_l towlower_l towupper_l wctrans_l towctrans_l access euidaccess eaccess faccessat lseek lseek64 close read write pread pwrite pread64 pwrite64 pipe pipe2 alarm sleep ualarm usleep pause chown fchown lchown fchownat chdir fchdir getcwd get_current_dir_name getwd dup dup2 dup3 execve fexecve execv execle execl execvp execlp execvpe nice _exit pathconf fpathconf sysconf confstr getpid getppid getpgrp getpgid setpgid setpgrp setsid getsid getuid geteuid getgid getegid getgroups group_member setuid setreuid seteuid setgid setregid setegid getresuid getresgid setresuid setresgid fork vfork ttyname ttyname_r isatty ttyslot link linkat symlink readlink symlinkat readlinkat unlink unlinkat rmdir tcgetpgrp tcsetpgrp getlogin getlogin_r setlogin gethostname sethostname sethostid getdomainname setdomainname vhangup revoke profil acct getusershell endusershell setusershell daemon chroot getpass fsync gethostid sync getpagesize getdtablesize truncate truncate64 ftruncate ftruncate64 brk sbrk syscall lockf lockf64 fdatasync crypt encrypt swab ctermid remove rename renameat tmpfile tmpfile64 tmpnam tmpnam_r tempnam fclose fflush fflush_unlocked fcloseall fopen freopen fopen64 freopen64 fdopen fopencookie fmemopen open_memstream setbuf setvbuf setbuffer setlinebuf fprintf printf sprintf vfprintf vprintf vsprintf snprintf vsnprintf vasprintf asprintf vdprintf dprintf fscanf scanf sscanf vfscanf vscanf vsscanf fgetc getc getchar getc_unlocked getchar_unlocked fgetc_unlocked fputc putc putchar fputc_unlocked putc_unlocked putchar_unlocked getw putw fgets gets fgets_unlocked getdelim getline fputs puts ungetc fread fwrite fputs_unlocked fread_unlocked fwrite_unlocked fseek ftell rewind fseeko ftello fgetpos fsetpos fseeko64 ftello64 fgetpos64 fsetpos64 clearerr feof ferror clearerr_unlocked feof_unlocked ferror_unlocked perror fileno fileno_unlocked popen pclose ctermid cuserid obstack_printf obstack_vprintf flockfile ftrylockfile funlockfile
syn keyword   cCPPType          istreambuf_iterator filebuf string ofstream ifstream stream istream_iterator istringstream ostream ostream_iterator ostringstream fstream auto_ptr pointer pointer_to_binary_function pointer_to_unary_function basic_string bit_vector bitset char_producer deque hash hash_map hash_multimap hash_multiset hash_set list map multimap multiset queue priority_queue rope set stack vector back_insert_iterator iterator bidirectional_iterator bidirectional_iterator_tag forward_iterator forward_iterator_tag front_insert_iterator input_iterator input_iterator_tag insert_iterator istream_iterator iterator_traits ostream_iterator output_iterator output_iterator_tag random_access_iterator random_access_iterator_tag raw_storage_iterator reverse_bidirectional_iterator reverse_iterator sequence_buffer binary_compose binary_function binary_negate binder1st binder2nd divides equal_to unary_compose unary_function unary_negate pair char_traits const_iterator reverse_iterator temporary_buffer
"syn keyword   cMFCType          CAnimateCtrl CArchive CArchiveException CArray CAsyncMonikerFile CAsyncScoket CBitmap CBitmapButton CBrush CButton CByteArray CCachedDataPathProperty CCheckListBox CClientDC CCmdTarget CCmdUI CColorDialog CComboBox CComboBoxEx CCommandLineInfo CCommonDialog CConnectionPoint CControlBar CCreateContext CCriticalSection CCtrlView CDaoDatabase CDaoException CDaoFieldExchange CDaoQueryDef CDaoRecordset CDaoRecordView CDaoTableDef CDaoWorkspace CDatabase CDataExchange CDataPathProperty CDateTimeCtrl CDBException CDBVariant CDC CDialog CDialogBar CDocItem CDockState CDocObjectServer CDocObjectServerItem CDocTemplate CDocument CDragListBox CDumpContext CDWordArray CEdit CEditView CEvent CException CFieldExchange CFile CFileDialog CFileException CFileFind CFindReplaceDialog CFont CFontDialog CFontHolder CFormView CFrameWnd CFtpConnection CFtpFileFind CGdiObject CGopherConnection CGopherFile CGopherFileFind CGopherLocator CHeaderCtrl CHotKeyCtrl CHtmlStream CHtmlView CHttpConnection CHttpFile CHttpFilter CHttpFilterContext CHttpServer CHttpServerContext CImageList CInternetConnection CInternetException CInternetFile CInternetSession CIPAddressCtrl CList CListBox CListCtrl ClistView CLongBinary CMap CMapPtrToPtr CMapPtrToWord CMapStringToOb CMapStringToPtr CMapStringToString CMapWordToOb CMapWordToPtr CMDIChildWnd CMDIFrameWnd CMemFile CMemoryException CMemoryState CMenu CMetaFileDC CMiniFrameWnd CMonikerFile CMonthCalCtrl CMultiDocTemplate CMultiLock CMutex CNotSupportedException CObArray CObject CObList COleBusyDialog COleChangeIconDialog COleChangeSourceDialog COleClientItem COleCmdUI COleControl COleControlModule COleConvertDialog COleCurrency COleDataObject COleDataSource COleDateTime COleDateTimeSpan COleDBRecordView COleDialog COleDispatchDriver COleDispatchException COleDocObjectItem COleDocument COleDropSource COleDropTarget COleException COleInsertDialog COleIPFrameWnd COleLinkingDoc COleLinksDialog COleMessageFilter COleObjectFactory COlePasteSpecialDialog COlePropertiesDialog COlePropertyPage COleResizeBar COleSafeArray COleServerDoc COleServerItem COleStreamFile COleTemplateServer COleUpdateDialog COleVariant CPageSetupDialog CPaintDC CPalette CPen CPictureHolder CPoint CPrintDialog CPrintInfo CProgressCtrl CPropertyPage CPropertyPageEx CPropertySheet CPropertySheetEx CPropExchange CPtrArray CPtrList CReBar CReBarCtrl CRecentFileList CRecordset CRecordView CRect CRectTracker CResourceException CRgn CRichEditCntrItem CRichEditCtrl CRichEditDoc CRichEditView CRuntimeClass CScrollBar CScrollView CSemaphore CSharedFile CSingleDocTemplate CSingleLock CSize CSliderCtrl CSocket CSocketFile CSpinButtonCtrl CSplitterWnd CStatic CStatusBar CStatusBarCtrl CStdioFile CString CStringArray CStringList CSyncObject CTabCtrl CTime CTimeSpan CToolBar CToolBarCtrl CToolTipCtrl CTreeCtrl CTreeView CTypedPtrArray CTypedPtrList CTypedPtrMap CUIntArray CUserException CView CWaitCursor CWinApp CWindowDC CWinThread CWnd CWordArray
"syn keyword   cWin32Type        __T _T APIENTRY ATOM BOOL TRUE FALSE BOOLEAN BYTE CALLBACK CCHAR CHAR COLORREF CONST DWORD DWORDLONG DWORD_PTR DWORD32 DWORD64 FLOAT HACCEL HALF_PTR HANDLE HBITMAP HBRUSH HCOLORSPACE HCONV HCONVLIST HCURSOR HDC HDDEDATA HDESK HDROP HDWP HENHMETAFILE HFILE HFONT HGDIOBJ HGLOBAL HHOOK HICON HINSTANCE HKEY HKL HLOCAL HMENU HMETAFILE HMODULE HMONITOR HPALETTE HPEN HRESULT HRGN HRSRC HSZ HWINSTA HWND INT INT_PTR INT8 INT16 INT32 INT64 LANGID LCID LCTYPE LGRPID LONG LONGLONG LONG_PTR LONG32 LONG64 LPARAM LPBOOL LPBYTE LPCOLORREF LPCSTR LPCTSTR LPCVOID LPCWSTR LPDWORD LPHANDLE LPINT LPLONG LPSTR LPTSTR LPVOID LPWORD LPWSTR LRESULT PBOOL PBOOLEAN PBYTE PCHAR PCSTR PCTSTR PCWSTR PDWORD PDWORDLONG PDWORD_PTR PDWORD32 PDWORD64 PFLOAT PHALF_PTR PHANDLE PHKEY PINT PINT_PTR PINT8 PINT16 PINT32 PINT64 PLCID PLONG PLONGLONG PLONG_PTR PLONG32 PLONG64 POINTER_32 POINTER_64 POINTER_SIGNED POINTER_UNSIGNED PSHORT PSIZE_T PSSIZE_T PSTR PTBYTE PTCHAR PTSTR PUCHAR PUHALF_PTR PUINT PUINT_PTR PUINT8 PUINT16 PUINT32 PUINT64 PULONG PULONGLONG PULONG_PTR PULONG32 PULONG64 PUSHORT PVOID PWCHAR PWORD PWSTR QWORD SC_HANDLE SC_LOCK SERVICE_STATUS_HANDLE SHORT SIZE_T SSIZE_T TBYTE TCHAR UCHAR UHALF_PTR UINT UINT_PTR UINT8 UINT16 UINT32 UINT64 ULONG ULONGLONG ULONG_PTR ULONG32 ULONG64 UNICODE_STRING USHORT USN VOID WCHAR WINAPI WORD WPARAM
"syn keyword   cWin32Function    _tprintf _ftprintf _stprintf _sntprintf _vtprintf _vftprintf _vstprintf _vsntprintf _tscanf _ftscanf _stscanf _fgettc _fgettchar _fgetts _fputtc _fputtchar _fputts _gettc _gettchar _getts _puttc _puttchar _putts _ungettc _tcstod _tcstol _tcstoul _itot _ltot _ultot _ttoi _ttol _ttoi64 _i64tot _ui64tot _tcscat _tcschr _tcscpy _tcscspn _tcslen _tcsncat _tcsncpy _tcspbrk _tcsrchr _tcsspn _tcsstr _tcstok _tcsdup _tcsnset _tcsrev _tcsset _tcscmp _tcsicmp _tcsnccmp _tcsncmp _tcsncicmp _tcsnicmp _tcscoll _tcsicoll _tcsnccoll _tcsncoll _tcsncicoll _tcsnicoll _texecl _texecle _texeclp _texeclpe _texecv _texecve _texecvp _texecvpe _tspawnl _tspawnle _tspawnlp _tspawnlpe _tspawnv _tspawnve _tspawnvp _tspawnvp _tspawnvpe _tsystem _tasctime _tctime _tstrdate _tstrtime _tutime _tcsftime _tchdir _tgetcwd _tgetdcwd _tmkdir _trmdir _tfullpath _tgetenv _tmakepath _tputenv _tsearchenv _tsplitpath _tfdopen _tfsopen _tfopen _tfreopen _tperror _tpopen _ttempnam _ttmpnam _taccess _tchmod _tcreat _tfindfirst _tfindfirsti64 _tfindnext _tfindnexti64 _tmktemp _topen _tremove _trename _tsopen _tunlink _tfinddata_t _tfinddatai64_t _tstat _tstati64 _tsetlocale _tcsclen _tcsnccat _tcsnccpy _tcsncset _tcsdec _tcsinc _tcsnbcnt _tcsnccnt _tcsnextc _tcsninc _tcsspnp _tcslwr _tcsupr _tcsxfrm _istalnum _istalpha _istascii _istcntrl _istdigit _istgraph _istlower _istprint _istpunct _istspace _istupper _istxdigit _totupper _totlower _istlegal _istlead _istleadbyte
hi def link cFunction           Function
hi def link cCPPType            Type
"hi def link cMFCType            Type
"hi def link cWin32Type          Type
"hi def link cWin32Function      Function

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
