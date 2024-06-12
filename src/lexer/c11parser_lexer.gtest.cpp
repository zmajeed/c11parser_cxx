//c11parser_lexer.gtest.cpp

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

#include "c11parser_lexer.h"

#include <sstream>
#include <string>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "c11parser.bison.h"

using namespace std;
using namespace ::testing;

namespace c11parser::testing {

using symbol_kind = C11Parser::symbol_kind;

TEST(Lexer, test_0) {

  stringstream s(R"%(
int main(void) {
  return 0;
}
)%");

  Lexer lexer(s);
  LexParam lexParam{};

  auto token = lexer.yylex(lexParam);
  EXPECT_EQ(token.kind(), symbol_kind::S_INT);

  EXPECT_EQ(lexer.yylex(lexParam).kind(), symbol_kind::S_NAME);
}

TEST(Lexer, test_1) {

  stringstream s(R"%(
int main(void) {
  return 0;
}
)%");

  Lexer lexer(s);
  lexer.options = {.atomic_strict_syntax = false};

  LexParam lexParam;

// fake lexical feedback callback
  lexParam.is_typedefname = [](const string& s) {
    if(s == "main") {
      return false;
    }
    return true;
  };

  auto token = lexer.yylex(lexParam);
  EXPECT_EQ(token.kind(), symbol_kind::S_INT);

  EXPECT_EQ(lexer.yylex(lexParam).kind(), symbol_kind::S_NAME);
  EXPECT_EQ(lexer.yylex(lexParam).kind(), symbol_kind::S_VARIABLE);
}

}

