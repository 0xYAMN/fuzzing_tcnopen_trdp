cmake_minimum_required(VERSION 3.16)
project(fuzzing_tcnopen_trdp LANGUAGES C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

find_package(Threads REQUIRED)
find_library(UUID_LIBRARY uuid REQUIRED)

set(TRDP_SRC_DIR "${CMAKE_SOURCE_DIR}/trdp/src")

set(TCNOPEN_SOURCES
    # VOS (POSIX)
    "${TRDP_SRC_DIR}/vos/common/vos_utils.c"
    "${TRDP_SRC_DIR}/vos/common/vos_mem.c"
    "${TRDP_SRC_DIR}/vos/posix/vos_sock.c"
    "${TRDP_SRC_DIR}/vos/posix/vos_thread.c"
    "${TRDP_SRC_DIR}/vos/posix/vos_shared_mem.c"
    # TRDP core (PD + MD)
    "${TRDP_SRC_DIR}/common/trdp_pdcom.c"
    "${TRDP_SRC_DIR}/common/trdp_utils.c"
    "${TRDP_SRC_DIR}/common/tlp_if.c"
    "${TRDP_SRC_DIR}/common/tlc_if.c"
    "${TRDP_SRC_DIR}/common/trdp_stats.c"
    "${TRDP_SRC_DIR}/common/trdp_mdcom.c"
    "${TRDP_SRC_DIR}/common/tlm_if.c"
    # TRDP optional: XML config parser, marshalling, DNR, TTI, service control
    "${TRDP_SRC_DIR}/common/trdp_xml.c"
    "${TRDP_SRC_DIR}/common/tau_xml.c"
    "${TRDP_SRC_DIR}/common/tau_marshall.c"
    "${TRDP_SRC_DIR}/common/tau_dnr.c"
    "${TRDP_SRC_DIR}/common/tau_tti.c"
    "${TRDP_SRC_DIR}/common/tau_ctrl.c"
)

add_library(tcnopen_trdp STATIC ${TCNOPEN_SOURCES})

target_include_directories(tcnopen_trdp SYSTEM PUBLIC
    "${TRDP_SRC_DIR}/api"
    "${TRDP_SRC_DIR}/vos/api"
    "${TRDP_SRC_DIR}/common"
    "${TRDP_SRC_DIR}/vos/posix"
)

target_compile_definitions(tcnopen_trdp PUBLIC
    POSIX
    L_ENDIAN
    _GNU_SOURCE
    HAS_UUID
    MD_SUPPORT=1
)

# Mirrors trdp/config/LINUX_X86_64_config's CFLAGS.
target_compile_options(tcnopen_trdp PRIVATE
    -Wall
    -fstrength-reduce
    -fno-builtin
    -fsigned-char
    -pthread
    -fPIC
    -Wno-unknown-pragmas
    -Wno-format
    -Wno-unused-label
    -Wno-unused-function
)

target_link_libraries(tcnopen_trdp PUBLIC
    Threads::Threads
    rt
    ${UUID_LIBRARY}
)

add_executable(parse_xml parse_xml.cpp)
target_link_libraries(parse_xml PRIVATE tcnopen_trdp)
