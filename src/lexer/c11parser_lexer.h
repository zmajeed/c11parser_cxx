#ifndef C11PARSER_LEXER_H
#define C11PARSER_LEXER_H
// c11parser_lexer.h

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

#include <string>

#include "c11parser_guard_flexlexer.h"
#include "c11parser.bison.h"

namespace c11parser {
using namespace std;

struct LexerOptions {
  bool atomic_strict_syntax = true;
  bool enableGccExtensions = false;
};

class Lexer: public yyFlexLexer {
public:

  LexerOptions options{};

public:

// can only declare here since flex generates the implementation
  C11Parser::symbol_type yylex(LexParam&);

  Lexer() = default;

  explicit Lexer(istream& yyin_arg): yyFlexLexer(&yyin_arg) {}

private:

  using yyFlexLexer::yylex;

private:

// member variables for data needed across yylex calls

// lexer states are the same as in the menhir/ocamllex lexer
// these states could be implemented as flex start condition states
// but I think it's nicer this way since there's no pattern matching involved
// and they're really meant for logic before or after a token is matched
  enum class lexer_state {
    SRegular,
    SAtomic,
    SIdent,
  } lexer_state = lexer_state::SRegular;

// identifier to lookup and disambiguate between VARIABLE and TYPE tokens in next yylex call
  string identifierToLookup;

private:

  C11Parser::symbol_type checkToken(const C11Parser::symbol_type& token) {

    using symbol_kind = C11Parser::symbol_kind;
    constexpr auto S_NAME = symbol_kind::S_NAME;
    constexpr auto S_LPAREN = symbol_kind::S_LPAREN;
    constexpr auto S_ATOMIC = symbol_kind::S_ATOMIC;

    constexpr auto SRegular = lexer_state::SRegular;
    constexpr auto SAtomic = lexer_state::SAtomic;
    constexpr auto SIdent = lexer_state::SIdent;

    switch(lexer_state) {
    case SAtomic:
    case SRegular:

// return first half of split token and prepare to send second half in next yylex call
      if(token.kind() == S_NAME) {
        identifierToLookup = token.value.as<string>();
        lexer_state = SIdent;
        return token;
      }

// check state for returning special ATOMIC_LPAREN token instead of plain parentheses following _Atomic
      if(lexer_state == SAtomic && token.kind() == S_LPAREN) {
        lexer_state = SRegular;
        return C11Parser::make_ATOMIC_LPAREN(token.location);
      }

// check strict C18 syntax option for how to handle possible parentheses after _Atomic
      if(token.kind() == S_ATOMIC) {
        lexer_state = options.atomic_strict_syntax? SAtomic: SRegular;
        return token;
      }

// default is to return the matched token as-is
      lexer_state = SRegular;
      return token;

// SIdent is the only other possible lexer state - it should never occur here since it is checked at yylex entry
    default:
      break;
    }

    throw C11Parser::syntax_error(token.location, "unexpected combination of lexer_state "s + to_string((int)lexer_state) + " and token " + to_string(token.kind()));
  }

};

}

#endif


