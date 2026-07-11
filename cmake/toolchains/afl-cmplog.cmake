# cmake/toolchains/afl-cmplog.cmake
#
# Usage:
#   cmake -B build-afl-cmplog -S . -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/afl-cmplog.cmake
#   cmake --build build-afl-cmplog

set(CMAKE_C_COMPILER   "${CMAKE_CURRENT_LIST_DIR}/wrappers/afl-clang-fast-cmplog"   CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/wrappers/afl-clang-fast++-cmplog" CACHE FILEPATH "" FORCE)
