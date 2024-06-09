#ifndef C11PARSER_DECLARATOR_H
#define C11PARSER_DECLARATOR_H
// declarator/declarator.h

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
#include <variant>

#include "context.h"

namespace {

template<class... Ts>
struct overload: Ts... { using Ts::operator()...; };

}

namespace c11parser {
using namespace std;

struct declarator;

struct declarator_base {
  string identifier;
};

struct identifier_declarator: public declarator_base {
};

struct function_declarator: public declarator_base {

  Context::State ctx;
  explicit function_declarator(const declarator&, const Context::State&);

};

struct other_declarator: public declarator_base {

  explicit other_declarator(const declarator& d);

};

struct declarator: variant<identifier_declarator, function_declarator, other_declarator> {
  using variant::variant;

  string identifier() {
    return visit(overload{
      [](const auto& d) -> string {
        return d.identifier;
      },
    },
    *this);
  }

  void reinstall_function_context(Context& context) {
    visit(overload{
      [&context](function_declarator& f) -> void { context.restore_context(f.ctx); context.declare_varname(f.identifier); },
      [](auto&) -> void {},
    },
    *this);
  }

};

inline function_declarator::function_declarator(const declarator& d, const Context::State& savedCtx) {
  visit(overload{
    [this, &savedCtx](const identifier_declarator& d) -> void {
      identifier = d.identifier;
      ctx = savedCtx;
    },
    [this](const function_declarator& d) -> void {
      identifier = d.identifier;
      ctx = d.ctx;
    },
    [this](const auto& d) -> void {
      identifier = d.identifier;
    }
  },
  d);
}

inline other_declarator::other_declarator(const declarator& d) {
  visit(overload{
    [this](const auto& d) -> void {
      identifier = d.identifier;
    }
  },
  d);
}

}

#endif

