# cmake/toolchains/afl-asan.cmake
#
# Usage:
#   cmake -B build-afl-asan -S . -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/afl-asan.cmake
#   cmake --build build-afl-asan

find_program(AFL_C_COMPILER   afl-clang-fast   REQUIRED)
find_program(AFL_CXX_COMPILER afl-clang-fast++ REQUIRED)

set(CMAKE_C_COMPILER   "${AFL_C_COMPILER}")
set(CMAKE_CXX_COMPILER "${AFL_CXX_COMPILER}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address -fno-omit-frame-pointer -g" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer -g" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address" CACHE STRING "" FORCE)
