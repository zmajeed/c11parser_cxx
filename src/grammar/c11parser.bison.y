// c11parser.bison.y

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

/*
Jacques-Henri Jourdan, Inria Paris
François Pottier, Inria Paris

Copyright (c) 2016-2017, Inria
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Inria nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL INRIA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// c++ parser skeleton file
%skeleton "lalr1.cc"

// minimum bison version 3.8
%require "3.8"

%language "c++"

// generate parser description report .output file
%verbose

// names of generated parser files
%defines "c11parser.bison.h"
%output "c11parser.bison.cpp"

// enable debug trace
%define parse.trace

// add location parameter to symbol constructor
%locations

// generate header for location to be used outside of bison parser
%define api.location.file "locations.bison.h"

%define parse.error detailed

// want to return character token from flex but don't think it can work with api.token.constructor
// better lookup performance at cost of disallowing literal characters in grammar
%define api.token.raw

%code requires {
// %code requires codeblock goes at top of .h outside of namespace and parser class
// standard c++ #includes and defines

#include <string>
#include <vector>
#include <functional>
#include <chrono>
#include <variant>
#include <optional>
#include <memory>

#include "locations.bison.h"

#include "declarator/context.h"
#include "declarator/declarator.h"

namespace c11parser {
using namespace std;
using namespace chrono;

// info for parser to use
struct BisonParam {
  Context context{};
  struct Stats {
    duration<double> parseTimeTakenSec;
    time_point<steady_clock> parseStartTime;
    time_point<steady_clock> parseEndTime;
  } stats{};
};

// info for lexer to use in yylex
struct LexParam {
// position in input stream for lexer to update
  location loc{};
// lexical feedback callbacks
  function<bool(const string&)> is_typedefname{};
};

}
}

// namespace for parser generated by bison
%define api.namespace {c11parser}

// name of generated parser class
%define api.parser.class {C11Parser}

// parser constructor parameter 1
// this is the yylex bison will call, it can have any signature we want since it's a lambda passed in by the client that wraps and hides the actual yylex call
%parse-param {function<C11Parser::symbol_type(LexParam&)> yylex}

// parser constructor parameter 2
%parse-param {BisonParam& bisonParam}

// parser constructor parameter 3
// only because each lex-param also must be parse-param
%parse-param {LexParam& lexParam}
// parser constructor parameter 2

// yylex parameter 1
// pass location and lexical feedback info to lexer
%lex-param {LexParam& lexParam}

// use c++ classes as semantic types
%define api.value.type variant

// use c++ objects, changes signature of yylex, yylex now returns PGNParser::symbol_type, yylex takes no parameters, change everywhere yylex is referenced, eg parse-param, any lambdas
%define api.token.constructor

// enable c++ assert via internal YY_ASSERT to validate symbol use
%define parse.assert

%code provides {
// %code provides codeblock goes in .h after namespace and parser class
// everything here needs BnfParser defined earlier

// parser objects
namespace c11parser {

using namespace std;

}

}

%code top {
// % code top
// appears as topmost code block in generated .cpp file just below gnu license

using namespace std;
}

%{
// %{ unnamed codeblock goes at very top of .cpp file before namespace and parser class

#include <sstream>

%}

%code {
// %code
// appears in generated .cpp file after #include of generated .h file and before parser namespace and class

#include <string>
#include <chrono>

using namespace std;

namespace {
  constexpr auto defaultInputName = "inputstream"s;
}

void c11parser::C11Parser::error(const location& loc, const string& msg) {
  cerr << "error at " << loc << ": " << msg << "\n";
}

}

%initial-action {
// %initial-action codeblock goes inside parse() function in .cpp, it's a separate brace-scoped block, anything declared here is local to this block and cannot be used anywhere else in parse()

  bisonParam.stats.parseStartTime = steady_clock::now();
  auto& loc = lexParam.loc;

  if(loc.begin.filename == nullptr) {
    loc.initialize(&defaultInputName);
  }

  if(!lexParam.is_typedefname) {
    lexParam.is_typedefname = [&context = bisonParam.context](const string& id) -> bool {
      return context.is_typedefname(id);
    };
  }
}

// token definitions

%token                               ADD_ASSIGN               "+="
%token                               ALIGNAS                  "_Alignas"
%token                               ALIGNOF                  "_Alignof"
%token                               AND                      "&"
%token                               ANDAND                   "&&"
%token                               AND_ASSIGN               "&="
%token                               ATOMIC                   "_Atomic"
%token                               ATOMIC_LPAREN
%token                               AUTO                     "auto"
%token                               BANG                     "!"
%token                               BAR                      "|"
%token                               BARBAR                   "||"
%token                               BOOL                     "_Bool"
%token                               BREAK                    "break"
%token                               CASE                     "case"
%token                               CHAR                     "char"
%token                               COLON                    ":"
%token                               COMMA                    ","
%token                               COMPLEX                  "_Complex"
%token                               CONST                    "const"
%token                               CONSTANT
%token                               CONTINUE                 "continue"
%token                               DEC                      "--"
%token                               DEFAULT                  "default"
%token                               DIV_ASSIGN               "/="
%token                               DO                       "do"
%token                               DOT                      "."
%token                               DOUBLE                   "double"
%token                               ELLIPSIS                 "..."
%token                               ELSE                     "else"
%token                               ENUM                     "enum"
%token                               EQ                       "="
%token                               EQEQ                     "=="
%token                               EXTERN                   "extern"
%token                               FLOAT                    "float"
%token                               FOR                      "for"
%token                               GENERIC                  "_Generic"
%token                               GEQ                      ">="
%token                               GOTO                     "goto"
%token                               GT                       ">"
%token                               HAT                      "^"
%token                               IF                       "if"
%token                               IMAGINARY                "_Imaginary"
%token                               INC                      "++"
%token                               INLINE                   "inline"
%token                               INT                      "int"
%token                               LBRACE                   "{"
%token                               LBRACK                   "["
%token                               LEFT                     "<<"
%token                               LEFT_ASSIGN              "<<="
%token                               LEQ                      "<="
%token                               LONG                     "long"
%token                               LPAREN                   "("
%token                               LT                       "<"
%token                               MINUS                     "-"
%token                               MOD_ASSIGN               "%="
%token                               MUL_ASSIGN               "*="
%token                               NEQ                      "!="
%token                               NORETURN                 "_Noreturn"
%token                               OR_ASSIGN                "|="
%token                               PERCENT                  "%"
%token                               PLUS                     "+"
%token                               PTR                      "->"
%token                               QUESTION                 "?"
%token                               RBRACE                   "}"
%token                               RBRACK                   "]"
%token                               REGISTER                 "register"
%token                               RESTRICT                 "restrict"
%token                               RETURN                   "return"
%token                               RIGHT                    ">>"
%token                               RIGHT_ASSIGN             ">>="
%token                               RPAREN                   ")"
%token                               SEMICOLON                ";"
%token                               SHORT                    "short"
%token                               SIGNED                   "signed"
%token                               SIZEOF                   "sizeof"
%token                               SLASH                    "/"
%token                               STAR                     "*"
%token                               STATIC                   "static"
%token                               STATIC_ASSERT            "_Static_assert"
%token                               STRING_LITERAL
%token                               STRUCT                   "struct"
%token                               SUB_ASSIGN               "-="
%token                               SWITCH                   "switch"
%token                               THREAD_LOCAL             "_Thread_local"
%token                               TILDE                    "~"
%token                               TYPE
%token                               TYPEDEF                  "typedef"
%token                               UNION                    "union"
%token                               UNSIGNED                 "unsigned"
%token                               VARIABLE
%token                               VOID                     "void"
%token                               VOLATILE                 "volatile"
%token                               WHILE                    "while"
%token                               XOR_ASSIGN               "^="

// tokens with values

%token <string>                      NAME

// nonterminals

%nterm <declarator>                  declarator
%nterm <declarator>                  declarator_typedefname
%nterm <declarator>                  declarator_varname
%nterm <declarator>                  direct_declarator

%nterm <string>                      enumeration_constant
%nterm <Context::context>            function_definition1
%nterm <string>                      general_identifier
%nterm <Context::context>            parameter_type_list
%nterm <Context::context>            save_context
%nterm <string>                      typedef_name
%nterm <string>                      var_name

%nterm <Context::context>            scoped_parameter_type_list_

%precedence below_ELSE
%precedence ELSE

// the start or root symbol of grammar
%start translation_unit_file

%%

translation_unit_file:
  external_declaration translation_unit_file
| external_declaration YYEOF

external_declaration:
  function_definition
| declaration

function_definition: function_definition1[ctx] option_declaration_list_ compound_statement {
  bisonParam.context.restore_context($ctx);
}

function_definition1: declaration_specifiers declarator_varname[d] {
  auto ctx = bisonParam.context.save_context();
  $d.reinstall_function_context(bisonParam.context);
  $$ = ctx;
}

option_declaration_list_:
  %empty
| declaration_list

declaration_list:
  declaration
| declaration_list declaration

declaration:
  declaration_specifiers option_init_declarator_list_declarator_varname__ ";"
| declaration_specifiers_typedef option_init_declarator_list_declarator_typedefname__ ";"
| static_assert_declaration

declaration_specifiers:
  list_eq1_type_specifier_unique_declaration_specifier_
| list_ge1_type_specifier_nonunique_declaration_specifier_

list_eq1_type_specifier_unique_declaration_specifier_:
  type_specifier_unique list_declaration_specifier_
| declaration_specifier list_eq1_type_specifier_unique_declaration_specifier_

list_ge1_type_specifier_nonunique_declaration_specifier_:
  type_specifier_nonunique list_declaration_specifier_
| type_specifier_nonunique list_ge1_type_specifier_nonunique_declaration_specifier_
| declaration_specifier list_ge1_type_specifier_nonunique_declaration_specifier_

option_init_declarator_list_declarator_varname__:
  %empty
| init_declarator_list_declarator_varname_

declaration_specifiers_typedef:
  list_eq1_eq1_TYPEDEF_type_specifier_unique_declaration_specifier_
| list_eq1_ge1_TYPEDEF_type_specifier_nonunique_declaration_specifier_

list_eq1_eq1_TYPEDEF_type_specifier_unique_declaration_specifier_:
  "typedef" list_eq1_type_specifier_unique_declaration_specifier_
| type_specifier_unique list_eq1_TYPEDEF_declaration_specifier_
| declaration_specifier list_eq1_eq1_TYPEDEF_type_specifier_unique_declaration_specifier_

list_eq1_ge1_TYPEDEF_type_specifier_nonunique_declaration_specifier_:
  "typedef" list_ge1_type_specifier_nonunique_declaration_specifier_
| type_specifier_nonunique list_eq1_TYPEDEF_declaration_specifier_
| type_specifier_nonunique list_eq1_ge1_TYPEDEF_type_specifier_nonunique_declaration_specifier_
| declaration_specifier list_eq1_ge1_TYPEDEF_type_specifier_nonunique_declaration_specifier_

option_init_declarator_list_declarator_typedefname__:
  %empty
| init_declarator_list_declarator_typedefname_

init_declarator_list_declarator_typedefname_:
  init_declarator_declarator_typedefname_
| init_declarator_list_declarator_typedefname_ "," init_declarator_declarator_typedefname_

init_declarator_list_declarator_varname_:
  init_declarator_declarator_varname_
| init_declarator_list_declarator_varname_ "," init_declarator_declarator_varname_

init_declarator_declarator_typedefname_:
  declarator_typedefname
| declarator_typedefname "=" c_initializer

init_declarator_declarator_varname_:
  declarator_varname
| declarator_varname "=" c_initializer

declarator_varname: declarator[d] {
  bisonParam.context.declare_varname($d.identifier());
  $$ = move($d);
}
;

declarator_typedefname: declarator[d] {
  bisonParam.context.declare_typedefname($d.identifier());
  $$ = move($d);
}
;

option_declarator_:
  %empty
| declarator

declarator: direct_declarator[d] {
  $$ = move($d);
}
| pointer direct_declarator[d] {
  $$ = move($d);
}
;

direct_declarator: general_identifier[i] {
  $$ = identifier_declarator{$i};
}
| "(" save_context declarator[d] ")" {
  $$ = move($d);
}
| direct_declarator[d] "[" option_type_qualifier_list_ option_assignment_expression_ "]" {
  $$ = other_declarator($d);
}
| direct_declarator[d] "[" "static" option_type_qualifier_list_ assignment_expression "]" {
  $$ = other_declarator($d);
}
| direct_declarator[d] "[" type_qualifier_list "static" assignment_expression "]" {
  $$ = other_declarator($d);
}
| direct_declarator[d] "[" option_type_qualifier_list_ "*" "]" {
  $$ = other_declarator($d);
}
| direct_declarator[d] "(" scoped_parameter_type_list_[ctx] ")" {
  $$ = function_declarator($d, $ctx);
}
| direct_declarator[d] "(" save_context option_identifier_list_ ")" {
  $$ = other_declarator($d);
}
;

option_type_qualifier_list_:
  %empty
| type_qualifier_list

scoped_parameter_type_list_: save_context[ctx] parameter_type_list[x] {
  bisonParam.context.restore_context($ctx);
  $$ = move($x);
}
;

static_assert_declaration:
  "_Static_assert" "(" constant_expression "," STRING_LITERAL ")" ";"

declaration_specifier:
  storage_class_specifier
| type_qualifier
| function_specifier
| alignment_specifier

storage_class_specifier:
  "extern"
| "static"
| "_Thread_local"
| "auto"
| "register"

type_qualifier:
  "const"
| "restrict"
| "volatile"
| "_Atomic"

function_specifier:
  "inline"
| "_Noreturn"

alignment_specifier:
  "_Alignas" "(" type_name ")"
| "_Alignas" "(" constant_expression ")"

compound_statement:
  "{" option_block_item_list_ "}"

option_block_item_list_:
  %empty
| block_item_list

block_item_list:
  option_block_item_list_ block_item

block_item:
  declaration
| statement

statement:
  labeled_statement
| scoped_compound_statement_
| expression_statement
| scoped_selection_statement_
| scoped_iteration_statement_
| jump_statement

labeled_statement:
  general_identifier ":" statement
| "case" constant_expression ":" statement
| "default" ":" statement

scoped_compound_statement_: save_context[ctx] compound_statement {
  bisonParam.context.restore_context($ctx);
}
;

expression_statement:
  option_expression_ ";"

option_expression_:
  %empty
| expression

scoped_selection_statement_: save_context[ctx] selection_statement {
  bisonParam.context.restore_context($ctx);
}
;

scoped_iteration_statement_: save_context[ctx] iteration_statement {
  bisonParam.context.restore_context($ctx);
}
;

jump_statement:
  "goto" general_identifier ";"
| "continue" ";"
| "break" ";"
| "return" option_expression_ ";"

selection_statement:
  "if" "(" expression ")" scoped_statement_ "else" scoped_statement_
| "if" "(" expression ")" scoped_statement_ %prec below_ELSE
| "switch" "(" expression ")" scoped_statement_

iteration_statement:
  "while" "(" expression ")" scoped_statement_
| "do" scoped_statement_ "while" "(" expression ")" ";"
| "for" "(" option_expression_ ";" option_expression_ ";" option_expression_ ")" scoped_statement_
| "for" "(" declaration option_expression_ ";" option_expression_ ")" scoped_statement_

scoped_statement_: save_context[ctx] statement {
  bisonParam.context.restore_context($ctx);
}
;

option_direct_abstract_declarator_:
  %empty
| direct_abstract_declarator

option_scoped_parameter_type_list__:
  %empty
| scoped_parameter_type_list_

list___anonymous_0_:
  %empty
| type_qualifier list___anonymous_0_
| alignment_specifier list___anonymous_0_

list___anonymous_1_:
  %empty
| type_qualifier list___anonymous_1_
| alignment_specifier list___anonymous_1_

list_declaration_specifier_:
  %empty
| declaration_specifier list_declaration_specifier_

list_eq1_TYPEDEF_declaration_specifier_:
  "typedef" list_declaration_specifier_
| declaration_specifier list_eq1_TYPEDEF_declaration_specifier_

list_eq1_type_specifier_unique___anonymous_0_:
  type_specifier_unique list___anonymous_0_
| type_qualifier list_eq1_type_specifier_unique___anonymous_0_
| alignment_specifier list_eq1_type_specifier_unique___anonymous_0_

list_ge1_type_specifier_nonunique___anonymous_1_:
  type_specifier_nonunique list___anonymous_1_
| type_specifier_nonunique list_ge1_type_specifier_nonunique___anonymous_1_
| type_qualifier list_ge1_type_specifier_nonunique___anonymous_1_
| alignment_specifier list_ge1_type_specifier_nonunique___anonymous_1_

option_general_identifier_:
  %empty
| general_identifier

// CAUTION keep typedef_name_spec and general_identifier rules together with typedef_name_spec above general_identifier
// this is required for the desired resolution of 3 reduce-reduce conflicts involving these two rules based on bison's default reduction using the earlier occurring rule
// see the bison report generated in the build for more details
typedef_name_spec:
  typedef_name

general_identifier: typedef_name[i] {
  $$ = move($i);
}
| var_name[i] {
  $$ = move($i);
}
;

typedef_name: NAME[i] TYPE {
  $$ = move($i);
}
;

var_name: NAME[i] VARIABLE {
  $$ = move($i);
}
;

unary_expression:
  postfix_expression
| "++" unary_expression
| "--" unary_expression
| unary_operator cast_expression
| "sizeof" unary_expression
| "sizeof" "(" type_name ")"
| "_Alignof" "(" type_name ")"

unary_operator:
  "&"
| "*"
| "+"
| "-"
| "~"
| "!"

postfix_expression:
  primary_expression
| postfix_expression "[" expression "]"
| postfix_expression "(" option_argument_expression_list_ ")"
| postfix_expression "." general_identifier
| postfix_expression "->" general_identifier
| postfix_expression "++"
| postfix_expression "--"
| "(" type_name ")" "{" initializer_list option_COMMA_ "}"

primary_expression:
  var_name
| CONSTANT
| STRING_LITERAL
| "(" expression ")"
| generic_selection

expression:
  assignment_expression
| expression "," assignment_expression

option_argument_expression_list_:
  %empty
| argument_expression_list

argument_expression_list:
  assignment_expression
| argument_expression_list "," assignment_expression

generic_selection:
"_Generic" "(" assignment_expression "," generic_assoc_list ")"

generic_assoc_list:
  generic_association
| generic_assoc_list "," generic_association

generic_association:
  type_name ":" assignment_expression
| "default" ":" assignment_expression

cast_expression:
  unary_expression
| "(" type_name ")" cast_expression

additive_expression:
  multiplicative_expression
| additive_expression additive_operator multiplicative_expression

additive_operator:
  "+"
| "-"

multiplicative_expression:
  cast_expression
| multiplicative_expression multiplicative_operator cast_expression

multiplicative_operator:
  "*"
| "/"
| "%"

relational_expression:
  shift_expression
| relational_expression relational_operator shift_expression

relational_operator:
  "<"
| ">"
| "<="
| ">="

shift_expression:
  additive_expression
| shift_expression shift_operator additive_expression

shift_operator:
  "<<"
| ">>"

constant_expression:
  conditional_expression

conditional_expression:
  logical_or_expression
| logical_or_expression "?" expression ":" conditional_expression

logical_or_expression:
  logical_and_expression
| logical_or_expression "||" logical_and_expression

logical_and_expression:
  inclusive_or_expression
| logical_and_expression "&&" inclusive_or_expression

inclusive_or_expression:
  exclusive_or_expression
| inclusive_or_expression "|" exclusive_or_expression

exclusive_or_expression:
  and_expression
| exclusive_or_expression "^" and_expression

and_expression:
  equality_expression
| and_expression "&" equality_expression

equality_expression:
  relational_expression
| equality_expression equality_operator relational_expression

equality_operator:
  "=="
| "!="

option_assignment_expression_:
  %empty
| assignment_expression

assignment_expression:
  conditional_expression
| unary_expression assignment_operator assignment_expression

assignment_operator:
  "="
| "*="
| "/="
| "%="
| "+="
| "-="
| "<<="
| ">>="
| "&="
| "^="
| "|="

type_specifier_nonunique:
  "char"
| "short"
| "int"
| "long"
| "float"
| "double"
| "signed"
| "unsigned"
| "_Complex"
| "_Imaginary"

type_specifier_unique:
  "void"
| "_Bool"
| atomic_type_specifier
| struct_or_union_specifier
| enum_specifier
| typedef_name_spec

struct_or_union_specifier:
  struct_or_union option_general_identifier_ "{" struct_declaration_list "}"
| struct_or_union general_identifier

struct_or_union:
  "struct"
| "union"

struct_declaration_list:
  struct_declaration
| struct_declaration_list struct_declaration

struct_declaration:
  specifier_qualifier_list option_struct_declarator_list_ ";"
| static_assert_declaration

specifier_qualifier_list:
  list_eq1_type_specifier_unique___anonymous_0_
| list_ge1_type_specifier_nonunique___anonymous_1_

option_struct_declarator_list_:
  %empty
| struct_declarator_list

struct_declarator_list:
  struct_declarator
| struct_declarator_list "," struct_declarator

struct_declarator:
  declarator
| option_declarator_ ":" constant_expression

enum_specifier:
  "enum" option_general_identifier_ "{" enumerator_list option_COMMA_ "}"
| "enum" general_identifier

enumerator_list:
  enumerator
| enumerator_list "," enumerator

enumerator: enumeration_constant[i] {
  bisonParam.context.declare_varname($i);
}
| enumeration_constant[i] "=" constant_expression {
  bisonParam.context.declare_varname($i);
}
;

enumeration_constant: general_identifier[i] {
  $$ = move($i);
}

atomic_type_specifier:
  "_Atomic" "(" type_name ")"
| "_Atomic" ATOMIC_LPAREN type_name ")"

pointer:
  "*" option_type_qualifier_list_ option_pointer_

option_pointer_: %empty | pointer

type_qualifier_list:
  option_type_qualifier_list_ type_qualifier

parameter_type_list: parameter_list option___anonymous_2_ save_context[ctx] {
  $$ = move($ctx);
}

parameter_list:
  parameter_declaration
| parameter_list "," parameter_declaration

parameter_declaration:
  declaration_specifiers declarator_varname
| declaration_specifiers option_abstract_declarator_

option_identifier_list_:
  %empty
| identifier_list

identifier_list:
  var_name
| identifier_list "," var_name

type_name:
  specifier_qualifier_list option_abstract_declarator_

option_abstract_declarator_:
  %empty
| abstract_declarator

abstract_declarator:
  pointer
| direct_abstract_declarator
| pointer direct_abstract_declarator

direct_abstract_declarator:
  "(" save_context abstract_declarator ")"
| option_direct_abstract_declarator_ "[" option_assignment_expression_ "]"
| option_direct_abstract_declarator_ "[" type_qualifier_list option_assignment_expression_ "]"
| option_direct_abstract_declarator_ "[" "static" option_type_qualifier_list_ assignment_expression "]"
| option_direct_abstract_declarator_ "[" type_qualifier_list "static" assignment_expression "]"
| option_direct_abstract_declarator_ "[" "*" "]"
| "(" option_scoped_parameter_type_list__ ")"
| direct_abstract_declarator "(" option_scoped_parameter_type_list__ ")"

initializer_list:
  option_designation_ c_initializer
| initializer_list "," option_designation_ c_initializer

option_designation_:
  %empty
| designation

designation:
  designator_list "="

designator_list:
  option_designator_list_ designator

option_designator_list_:
  %empty
| designator_list

designator:
  "[" constant_expression "]"
| "." general_identifier

c_initializer:
  assignment_expression
| "{" initializer_list option_COMMA_ "}"

option_COMMA_:
  %empty
| ","

option___anonymous_2_:
  %empty
| "," "..."

// midrule actions

save_context: %empty {
  $$ = bisonParam.context.save_context();
}
;

%%

// %code epilog block goes at bottom of generated .cpp file after namespace and parser implementation

#ifdef BUILD_BISON_MAIN

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>

#include <string>
#include <iostream>
#include <optional>

#include "lexer/c11parser_lexer.h"
#include "c11parser.bison.h"

using namespace std;

using namespace c11parser;

void usage() {
  puts("Usage: c11parse [-h | --help] [--debug]");
  puts("It prints nothing if input is valid, otherwise it prints an error message with line numbers");
  puts("");
  puts("Options:");
  puts("--debug: turns on Bison parser and Flex lexer debug traces, off by default");
  puts("--stats: print timing stats on successful parse, off by default");
  puts("--help | -h: prints usage help");
}

int main(int argc, char* argv[])
{
  ios_base::sync_with_stdio(false);

  bool atomicPermissiveSyntax = false;
  bool debug{};
  bool printStats{};

  auto inputFilename = "stdin"s;
  string changefile;

  option opts[] = {
    {"atomic-permissive-syntax", no_argument, (int*)&atomicPermissiveSyntax, 0},
    {"debug", no_argument, (int*)&debug, 1},
    {"stats", no_argument, (int*)&printStats, 1},
    {"help", no_argument, 0, 'h'},
    {0, 0, 0, 0}
  };

  for(int i, optLetter; (optLetter = getopt_long(argc, argv, "h", opts, &i)) != -1;) {
    switch(optLetter) {
    case 0:
      break;
    case 'h':
      usage();
      return 0;
    case '?':
      usage();
      return 1;
    default:
      break;
    }
  }

  Lexer lexer;
  lexer.options = {.atomic_strict_syntax = !atomicPermissiveSyntax};

  BisonParam bisonParam;
  LexParam lexParam{.loc = location(&inputFilename)};

  C11Parser parser([&lexer](LexParam& lexParam) -> C11Parser::symbol_type {
    return lexer.yylex(lexParam);
  },
  bisonParam,
  lexParam);

  lexer.set_debug(debug);
  parser.set_debug_level(debug);

  if(auto ev = parser(); ev != 0) {
    fputs("parse failed\n", stderr);
    return ev;
  }

  if(printStats) {
    const auto& stats = bisonParam.stats;

    printf("parse_time %.9f sec\n", stats.parseTimeTakenSec.count());
  }

  return 0;
}

#endif

