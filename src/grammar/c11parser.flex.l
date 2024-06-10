/* c11parser.flex.l */

/*
MIT License

Copyright (c) 2024 Zartaj Majeed

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

 // c++-style comments can start at second column outside rules section
/* c-style commens can start at first column outside rules section */

 // c++ scanner
%option c++

 // custom c++ lexer class
%option yyclass="Lexer"

 // custom prefix to rename yyFlexLexer class in flex header to C11FlexLexer
%option prefix="C11Parser"

 // enable states stack
 // needed for CHAR state used recursively by two states, CHAR_LITERAL_END and STRING_LITERAL
%option stack

%option warn

%option 8bit

%option debug

%option nodefault

%option never-interactive

%option noyywrap

%option nounput noinput batch

 // flex start conditions ie states

%x S_IDENT
%x INITIAL_LINEBEGIN
%x MULTILINE_COMMENT
%x SINGLELINE_COMMENT
%x CHAR
%x CHAR_LITERAL_END
%x STRING_LITERAL
%x HASH

 // named regexes

digit [0-9]
hexadecimal_digit [0-9A-Fa-f]
nondigit [_a-zA-Z]

hex_quad {hexadecimal_digit}{4}

universal_character_name "\\u"{hex_quad}|"\\U"{hex_quad}{2}

identifier_nondigit {nondigit}|{universal_character_name}

identifier {identifier_nondigit}({identifier_nondigit}|{digit})*

 // whitespace
whitespace_char_no_newline [ \t\012\r]

 // integer constants
nonzero_digit [1-9]
decimal_constant {nonzero_digit}{digit}*

octal_digit [0-7]
octal_constant 0{octal_digit}*

hexadecimal_prefix 0x|0X
hexadecimal_constant {hexadecimal_prefix}{hexadecimal_digit}+

unsigned_suffix [uU]
long_suffix [lL]
long_long_suffix ll|LL
integer_suffix {unsigned_suffix}{long_suffix}?|{unsigned_suffix}{long_long_suffix}|{long_suffix}{unsigned_suffix}?|{long_long_suffix}{unsigned_suffix}?

integer_constant {decimal_constant}{integer_suffix}?|{octal_constant}{integer_suffix}?|{hexadecimal_constant}{integer_suffix}?

 //Floating constants
sign [-+]

digit_sequence {digit}+
floating_suffix [flFL]

fractional_constant {digit_sequence}?"."{digit_sequence}|{digit_sequence}"."
exponent_part [eE]{sign}?{digit_sequence}
decimal_floating_constant {fractional_constant}{exponent_part}?{floating_suffix}?|{digit_sequence}{exponent_part}{floating_suffix}?

hexadecimal_digit_sequence {hexadecimal_digit}+
hexadecimal_fractional_constant {hexadecimal_digit_sequence}?"."{hexadecimal_digit_sequence}|{hexadecimal_digit_sequence}"."
binary_exponent_part [pP]{sign}?{digit_sequence}
hexadecimal_floating_constant {hexadecimal_prefix}{hexadecimal_fractional_constant}{binary_exponent_part}{floating_suffix}?|{hexadecimal_prefix}{hexadecimal_digit_sequence}{binary_exponent_part}{floating_suffix}?

 //Preprocessing numbers
preprocessing_number "."?[0-9]([0-9A-Za-z_.]|[eEpP][-+])*

 //Character and string constants
simple_escape_sequence \\['\"?\\abfnrtv]
octal_escape_sequence \\({octal_digit}{1,2}|{octal_digit}{4})
hexadecimal_escape_sequence \\x{hexadecimal_digit}+
escape_sequence {simple_escape_sequence}|{octal_escape_sequence}|{hexadecimal_escape_sequence}|{universal_character_name}


%top{
// appears at top of generated .cpp file
}

%{
// appears after flex state tables and before start state defines before yylex in generated .cpp file

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string>

#include <fmt/format.h>

// bison generated header with C++ namespace and token definitions
#include "c11parser.bison.h"
#include "lexer/c11parser_lexer.h"

#undef YY_DECL
#define YY_DECL c11parser::C11Parser::symbol_type c11parser::Lexer::yylex(LexParam& param)

// fix flex error could not convert 0 from int to symbol_type for #define YY_NULL 0
// caused by turning on bison %locations because symbol_type no longer has single int constructor for implicit conversion
#define yyterminate() return symbol_type(YY_NULL, loc)

// start out input in INITIAL_LINEBEGIN state
#define YY_USER_INIT BEGIN(INITIAL_LINEBEGIN);

using namespace std;
using namespace fmt;
using namespace c11parser;

// needed for custom yyterminate
using symbol_type = C11Parser::symbol_type;

%}

%%

 // code appears inside yylex function at start

 // position in input stream
  auto& loc = param.loc;
 // update current position to previous line and column numbers
  loc.step();

 // check for second half of special split token, return either NAME TYPE or NAME VARIABLE
  if(YY_START == S_IDENT) {
    BEGIN(0);
    auto isType = param.is_typedefname(identifierToLookup);
    if(debug() != 0) {
      println("yylex.entry_name_lookup: identifierToLookup {} isType {}", identifierToLookup, isType);
    }
    identifierToLookup.clear();
    return isType? C11Parser::make_TYPE(loc): C11Parser::make_VARIABLE(loc);
  }

 // flex rules section
 /* only c-style comments starting at second column allowed inside rules section */

 // important note: see YY_USER_INIT defined above that makes input processing start in INITIAL_LINEBEGIN state not default INITIAL state

<INITIAL_LINEBEGIN>{

\n+ {
  loc.lines(yyleng);
}

{whitespace_char_no_newline}+ {
  loc.columns(yyleng);
}

 /*
preprocessor lines start with # or its digraph %:
# 1 "/usr/include/stdio.h" 1 3 4
*/
#|%: {
  loc.columns(yyleng);
  BEGIN(HASH);
}

. {
    BEGIN(0);
    yyless(0);
  }

}

"/*" {
  loc.columns(yyleng);
  BEGIN(MULTILINE_COMMENT);
}

"//" {
  loc.columns(yyleng);
  BEGIN(SINGLELINE_COMMENT);
}

[LuU]?['] {
  loc.columns(yyleng);
  yy_push_state(CHAR_LITERAL_END);
  yy_push_state(CHAR);
}

([LuU]|u8)?["] {
  loc.columns(yyleng);
  BEGIN(STRING_LITERAL);
}

{integer_constant} {
  loc.columns(yyleng);
  return C11Parser::make_CONSTANT(loc);
}

{decimal_floating_constant} {
  loc.columns(yyleng);
  return C11Parser::make_CONSTANT(loc);
}

{hexadecimal_floating_constant} {
  loc.columns(yyleng);
  return C11Parser::make_CONSTANT(loc);
}

{preprocessing_number} {
  loc.columns(yyleng);
  throw C11Parser::syntax_error(loc, "these characters forma preprocessor number, but not a constant \""s + yytext + "\""s);
}

"..." {
  loc.columns(yyleng);
  return C11Parser::make_ELLIPSIS(loc);
}

"+=" {
  loc.columns(yyleng);
  return C11Parser::make_ADD_ASSIGN(loc);
}

-= {
  loc.columns(yyleng);
  return C11Parser::make_SUB_ASSIGN(loc);
}

"*=" {
  loc.columns(yyleng);
  return C11Parser::make_MUL_ASSIGN(loc);
}

"/=" {
  loc.columns(yyleng);
  return C11Parser::make_DIV_ASSIGN(loc);
}

%= {
  loc.columns(yyleng);
  return C11Parser::make_MOD_ASSIGN(loc);
}

"|=" {
  loc.columns(yyleng);
  return C11Parser::make_OR_ASSIGN(loc);
}

&= {
  loc.columns(yyleng);
  return C11Parser::make_AND_ASSIGN(loc);
}

"^=" {
  loc.columns(yyleng);
  return C11Parser::make_XOR_ASSIGN(loc);
}

"<<=" {
  loc.columns(yyleng);
  return C11Parser::make_LEFT_ASSIGN(loc);
}

>>= {
  loc.columns(yyleng);
  return C11Parser::make_RIGHT_ASSIGN(loc);
}

"<<" {
  loc.columns(yyleng);
  return C11Parser::make_LEFT(loc);
}

>> {
  loc.columns(yyleng);
  return C11Parser::make_RIGHT(loc);
}

== {
  loc.columns(yyleng);
  return C11Parser::make_EQEQ(loc);
}

!= {
  loc.columns(yyleng);
  return C11Parser::make_NEQ(loc);
}

"<=" {
  loc.columns(yyleng);
  return C11Parser::make_LEQ(loc);
}

>= {
  loc.columns(yyleng);
  return C11Parser::make_GEQ(loc);
}

= {
  loc.columns(yyleng);
  return C11Parser::make_EQ(loc);
}

"<" {
  loc.columns(yyleng);
  return C11Parser::make_LT(loc);
}

> {
  loc.columns(yyleng);
  return C11Parser::make_GT(loc);
}

"++" {
  loc.columns(yyleng);
  return C11Parser::make_INC(loc);
}

-- {
  loc.columns(yyleng);
  return C11Parser::make_DEC(loc);
}

-> {
  loc.columns(yyleng);
  return C11Parser::make_PTR(loc);
}

"+" {
  loc.columns(yyleng);
  return C11Parser::make_PLUS(loc);
}

- {
  loc.columns(yyleng);
  return C11Parser::make_MINUS(loc);
}

"*" {
  loc.columns(yyleng);
  return C11Parser::make_STAR(loc);
}

"/" {
  loc.columns(yyleng);
  return C11Parser::make_SLASH(loc);
}

% {
  loc.columns(yyleng);
  return C11Parser::make_PERCENT(loc);
}

! {
  loc.columns(yyleng);
  return C11Parser::make_BANG(loc);
}

&& {
  loc.columns(yyleng);
  return C11Parser::make_ANDAND(loc);
}

"||" {
  loc.columns(yyleng);
  return C11Parser::make_BARBAR(loc);
}

& {
  loc.columns(yyleng);
  return C11Parser::make_AND(loc);
}

"|" {
  loc.columns(yyleng);
  return C11Parser::make_BAR(loc);
}

"^" {
  loc.columns(yyleng);
  return C11Parser::make_HAT(loc);
}

"?" {
  loc.columns(yyleng);
  return C11Parser::make_QUESTION(loc);
}

: {
  loc.columns(yyleng);
  return C11Parser::make_COLON(loc);
}

~ {
  loc.columns(yyleng);
  return C11Parser::make_TILDE(loc);
}

"{" {
  loc.columns(yyleng);
  return C11Parser::make_LBRACE(loc);
}

"}" {
  loc.columns(yyleng);
  return C11Parser::make_RBRACE(loc);
}

"[" {
  loc.columns(yyleng);
  return C11Parser::make_LBRACK(loc);
}

"]" {
  loc.columns(yyleng);
  return C11Parser::make_RBRACK(loc);
}

"(" {
  loc.columns(yyleng);
  return C11Parser::make_LPAREN(loc);
}

")" {
  loc.columns(yyleng);
  return C11Parser::make_RPAREN(loc);
}

; {
  loc.columns(yyleng);
  return C11Parser::make_SEMICOLON(loc);
}

, {
  loc.columns(yyleng);
  return C11Parser::make_COMMA(loc);
}

"." {
  loc.columns(yyleng);
  return C11Parser::make_DOT(loc);
}

_Alignas {
  loc.columns(yyleng);
  return C11Parser::make_ALIGNAS(loc);
}

_Alignof {
  loc.columns(yyleng);
  return C11Parser::make_ALIGNOF(loc);
}

_Atomic {
  loc.columns(yyleng);
  return C11Parser::make_ATOMIC(loc);
}

_Bool {
  loc.columns(yyleng);
  return C11Parser::make_BOOL(loc);
}

_Complex {
  loc.columns(yyleng);
  return C11Parser::make_COMPLEX(loc);
}

_Generic {
  loc.columns(yyleng);
  return C11Parser::make_GENERIC(loc);
}

_Imaginary {
  loc.columns(yyleng);
  return C11Parser::make_IMAGINARY(loc);
}

_Noreturn {
  loc.columns(yyleng);
  return C11Parser::make_NORETURN(loc);
}

_Static_assert {
  loc.columns(yyleng);
  return C11Parser::make_STATIC_ASSERT(loc);
}

_Thread_local {
  loc.columns(yyleng);
  return C11Parser::make_THREAD_LOCAL(loc);
}

auto {
  loc.columns(yyleng);
  return C11Parser::make_AUTO(loc);
}

break {
  loc.columns(yyleng);
  return C11Parser::make_BREAK(loc);
}

case {
  loc.columns(yyleng);
  return C11Parser::make_CASE(loc);
}

char {
  loc.columns(yyleng);
  return C11Parser::make_CHAR(loc);
}

const {
  loc.columns(yyleng);
  return C11Parser::make_CONST(loc);
}

continue {
  loc.columns(yyleng);
  return C11Parser::make_CONTINUE(loc);
}

default {
  loc.columns(yyleng);
  return C11Parser::make_DEFAULT(loc);
}

do {
  loc.columns(yyleng);
  return C11Parser::make_DO(loc);
}

double {
  loc.columns(yyleng);
  return C11Parser::make_DOUBLE(loc);
}

else {
  loc.columns(yyleng);
  return C11Parser::make_ELSE(loc);
}

enum {
  loc.columns(yyleng);
  return C11Parser::make_ENUM(loc);
}

extern {
  loc.columns(yyleng);
  return C11Parser::make_EXTERN(loc);
}

float {
  loc.columns(yyleng);
  return C11Parser::make_FLOAT(loc);
}

for {
  loc.columns(yyleng);
  return C11Parser::make_FOR(loc);
}

goto {
  loc.columns(yyleng);
  return C11Parser::make_GOTO(loc);
}

if {
  loc.columns(yyleng);
  return C11Parser::make_IF(loc);
}

inline {
  loc.columns(yyleng);
  return C11Parser::make_INLINE(loc);
}

int {
  loc.columns(yyleng);
  return C11Parser::make_INT(loc);
}

long {
  loc.columns(yyleng);
  return C11Parser::make_LONG(loc);
}

register {
  loc.columns(yyleng);
  return C11Parser::make_REGISTER(loc);
}

restrict {
  loc.columns(yyleng);
  return C11Parser::make_RESTRICT(loc);
}

return {
  loc.columns(yyleng);
  return C11Parser::make_RETURN(loc);
}

short {
  loc.columns(yyleng);
  return C11Parser::make_SHORT(loc);
}

signed {
  loc.columns(yyleng);
  return C11Parser::make_SIGNED(loc);
}

sizeof {
  loc.columns(yyleng);
  return C11Parser::make_SIZEOF(loc);
}

static {
  loc.columns(yyleng);
  return C11Parser::make_STATIC(loc);
}

struct {
  loc.columns(yyleng);
  return C11Parser::make_STRUCT(loc);
}

switch {
  loc.columns(yyleng);
  return C11Parser::make_SWITCH(loc);
}

typedef {
  loc.columns(yyleng);
  return C11Parser::make_TYPEDEF(loc);
}

union {
  loc.columns(yyleng);
  return C11Parser::make_UNION(loc);
}

unsigned {
  loc.columns(yyleng);
  return C11Parser::make_UNSIGNED(loc);
}

void {
  loc.columns(yyleng);
  return C11Parser::make_VOID(loc);
}

volatile {
  loc.columns(yyleng);
  return C11Parser::make_VOLATILE(loc);
}

while {
  loc.columns(yyleng);
  return C11Parser::make_WHILE(loc);
}

 /* first half of a split token, NAME TYPE or NAME VARIABLE */
 /* second half is returned after a lookup in S_IDENT state at the start of yylex */
{identifier} {
  loc.columns(yyleng);
  identifierToLookup = yytext;
  BEGIN(S_IDENT);
  return C11Parser::make_NAME(identifierToLookup, loc);
}

 /* match newlines separately to correctly update line numbers */
\n {
  loc.lines();
  BEGIN(INITIAL_LINEBEGIN);
}

 /* whitespace except newline, same as [ \t\v\f\r] but easier to understand */
{whitespace_char_no_newline}+ {
  loc.columns(yyleng);
}

<MULTILINE_COMMENT>{

"*/" {
    loc.columns(yyleng);
    BEGIN(0);
  }

\n loc.lines();

. loc.columns(yyleng);

}

<SINGLELINE_COMMENT>{

  \n {
    loc.lines();
    BEGIN(INITIAL_LINEBEGIN);
  }

  .+ loc.columns(yyleng);

}

 /* common state used for singlequote character and doublequote string literals */
<CHAR>{

{simple_escape_sequence} {
    loc.columns(yyleng);
    yy_pop_state();

  }
{octal_escape_sequence} {
    loc.columns(yyleng);
    yy_pop_state();
  }
{hexadecimal_escape_sequence} {
    loc.columns(yyleng);
    yy_pop_state();
  }
{universal_character_name} {
    loc.columns(yyleng);
    yy_pop_state();
  }

"\\". {
    loc.columns(yyleng);
    throw C11Parser::syntax_error(loc, "incorrect escape sequence \""s + yytext + "\""s);
  }

. {
    loc.columns(yyleng);
    yy_pop_state();
  }

}

<CHAR_LITERAL_END>{

['] {
    loc.columns(yyleng);
    yy_pop_state();
    BEGIN(0);
    return C11Parser::make_CONSTANT(loc);
  }

\n {
    loc.lines();
    throw C11Parser::syntax_error(loc, "missing terminating singlequote ' character");
  }

. {
    yy_push_state(CHAR);
    yyless(0);
  }

}

<STRING_LITERAL>{
["] {
    loc.columns(yyleng);
    yy_pop_state();
    BEGIN(0);
    return C11Parser::make_STRING_LITERAL(loc);
  }
\n {
    loc.lines();
    throw C11Parser::syntax_error(loc, "missing terminating doublequote \" character");
  }
. {
    yy_push_state(CHAR);
    yyless(0);
  }
}

<HASH>{
 /*
preprocessor lines look like
# 1 "/usr/include/stdio.h" 1 3 4
*/

{whitespace_char_no_newline}+{digit}*{whitespace_char_no_newline}*["][^\n"]*["].*\n |

{whitespace_char_no_newline}*pragma{whitespace_char_no_newline}+.*\n {
    loc.columns(yyleng - 1);
    loc.lines();
    BEGIN(INITIAL_LINEBEGIN);
  }

.* {
    loc.columns(yyleng);
  }

}

 /* catchall */
<*>.|\n {
  loc.columns(yyleng);
  throw C11Parser::syntax_error(loc, "bad input \""s + yytext + "\""s);

}
