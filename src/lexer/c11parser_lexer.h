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

#include "c11parser_guard_flexlexer.h"
#include "c11parser.bison.h"

namespace c11parser {
using namespace std;

class Lexer: public yyFlexLexer {
public:

// can only declare here since flex generates the implementation
  C11Parser::symbol_type yylex(LexParam&);

  Lexer() = default;

  explicit Lexer(istream& yyin_arg): yyFlexLexer(&yyin_arg) {}

private:

  using yyFlexLexer::yylex;

private:

// member variables for data needed across yylex calls
  string identifierToLookup;

};

}

#endif


