#ifndef C11PARSER_CONTEXT_H
#define C11PARSER_CONTEXT_H
// declarator/context.h

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
#include <unordered_set>

namespace c11parser {
using namespace std;

struct Context {
  using context = unordered_set<string>;

  context current;

  bool is_typedefname(const string& id) {
    return current.contains(id);
  }

  void declare_typedefname(const string& id) {
    current.insert(id);
  }

  void declare_varname(const string& id) {
    current.erase(id);
  }

  context save_context() {
    return current;
  }

  void restore_context(const context& snapshot) {
    current = snapshot;
  }

};

}

#endif

