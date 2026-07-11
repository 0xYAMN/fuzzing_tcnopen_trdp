# cmake/toolchains/afl.cmake
#
# Usage:
#   cmake -B build-afl -S . -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/afl.cmake
#   cmake --build build-afl

find_program(AFL_C_COMPILER   afl-clang-fast   REQUIRED)
find_program(AFL_CXX_COMPILER afl-clang-fast++ REQUIRED)

set(CMAKE_C_COMPILER   "${AFL_C_COMPILER}")
set(CMAKE_CXX_COMPILER "${AFL_CXX_COMPILER}")
