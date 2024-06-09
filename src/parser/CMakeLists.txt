# c11parser/parser/CMakeLists.txt

project(c11parser_parser)

# standalone parser executable with -D BUILD_BISON_MAIN
set(PARSER_EXE c11parse)

add_executable(${PARSER_EXE} ${C11PARSER_BISON_CPP_FILE})
target_compile_definitions(${PARSER_EXE} PRIVATE BUILD_BISON_MAIN)
target_link_libraries(${PARSER_EXE} ${C11PARSER_FLEXBISONLIB} fmt)

if(CYGWIN)
  target_compile_definitions(${PARSER_EXE} PRIVATE GTEST_HAS_PTHREAD=1 _POSIX_C_SOURCE=200809L)
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
  target_compile_options(${PARSER_EXE} PRIVATE -Wall -Werror -Wextra -O0 -ggdb -std=c++23 -pthread)
elseif(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
# ranges library cannot take -Wall -WX
target_compile_options(${PARSER_EXE} PRIVATE -Od)
elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  target_compile_definitions(${PARSER_EXE} PRIVATE _SILENCE_CLANG_CONCEPTS_MESSAGE)
endif()

# tests

set(TESTNAME c11parser.gtest)

add_executable(${TESTNAME} c11parser.gtest.cpp)

if(CYGWIN)
  target_compile_definitions(${TESTNAME} PRIVATE GTEST_HAS_PTHREAD=1 _POSIX_C_SOURCE=200809L)
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
  target_compile_options(${TESTNAME} PRIVATE -Wall -Werror -Wextra -O0 -ggdb -std=c++23 -pthread)
elseif(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
# ranges library cannot take -Wall -WX
  target_compile_options(${TESTNAME} PRIVATE -Od)
elseif(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  target_compile_definitions(${TESTNAME} PRIVATE _SILENCE_CLANG_CONCEPTS_MESSAGE)
endif()

target_link_libraries(${TESTNAME} ${C11PARSER_FLEXBISONLIB} gmock_main fmt)

enable_testing()
include(GoogleTest)
gtest_discover_tests(${TESTNAME} EXTRA_ARGS --gtest_color=yes)

