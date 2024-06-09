# c11parser/grammar/CMakeLists.txt

project(c11parser_grammar)

find_package(FLEX)
find_package(BISON)

# generated source filename should match .l filename
flex_target(flex_files c11parser.flex.l ${CMAKE_CURRENT_BINARY_DIR}/c11parser.flex.cpp COMPILE_FLAGS -f)

# generated source filename should match .y filename
bison_target(bison_files c11parser.bison.y ${CMAKE_CURRENT_BINARY_DIR}/c11parser.bison.cpp COMPILE_FLAGS "-Wall -Wdangling-alias --report lookaheads,cex,solved --report-file bisonreport.lookaheads.cex.solved.txt")

add_flex_bison_dependency(flex_files bison_files)

set(C11PARSER_BISON_CPP_FILE ${BISON_bison_files_OUTPUT_SOURCE} CACHE STRING "" FORCE)
set(C11PARSER_FLEX_CPP_FILE ${FLEX_flex_files_OUTPUTS} CACHE STRING "" FORCE)

set(C11PARSER_FLEXBISONLIB flexbisonlib.c11parser CACHE STRING "" FORCE)

add_library(${C11PARSER_FLEXBISONLIB} STATIC ${FLEX_flex_files_OUTPUTS} ${BISON_bison_files_OUTPUT_SOURCE})
target_compile_definitions(${C11PARSER_FLEXBISONLIB} PRIVATE _POSIX_C_SOURCE=200809L)
target_compile_options(${C11PARSER_FLEXBISONLIB} PRIVATE -Wall -Werror -Wextra -O0 -ggdb -std=c++23 -pthread)
target_include_directories(${C11PARSER_FLEXBISONLIB} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(${C11PARSER_FLEXBISONLIB} fmt)


