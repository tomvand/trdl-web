cmake_minimum_required(VERSION 3.16)
project(trdl LANGUAGES CXX)

# ------------------------------------------------------------
# Options
# ------------------------------------------------------------

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set_property(GLOBAL PROPERTY TARGET_MESSAGES OFF)

# Generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ------------------------------------------------------------
# Compiler flags (C+ style)
# ------------------------------------------------------------

add_compile_options(
    -g3
    -Os
    -Wall
    -Wextra
    -Werror
    -Wdouble-promotion
    -Wformat=2
    -Wshadow
    -Wundef
    -Wunused
    -ffunction-sections
    -fno-common
    -fno-exceptions
)

add_compile_definitions(
    DOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS
)

# ------------------------------------------------------------
# Include paths
# ------------------------------------------------------------

include_directories(
    src/arduino
    src/client
    src/common
    src/server
    src/tests
    src/trdl

    lib/buddy_alloc
    lib/doctest/doctest
    lib/etl/include
)

# ------------------------------------------------------------
# Source collection (explicit, no glob magic later)
# ------------------------------------------------------------

file(GLOB_RECURSE INO_ARDUINO     src/arduino/*.ino)

file(GLOB_RECURSE SRCS_ARDUINO    src/arduino/*.cpp)
file(GLOB_RECURSE SRCS_CLIENT     src/client/*.cpp)
file(GLOB_RECURSE SRCS_COMMON     src/common/*.cpp)
file(GLOB_RECURSE SRCS_SERVER     src/server/*.cpp)
file(GLOB_RECURSE SRCS_TEST       src/tests/*.cpp)
file(GLOB_RECURSE SRCS_TRDL       src/trdl/*.cpp)

file(GLOB_RECURSE HDRS_ARDUINO    src/ardino/*.h*)
file(GLOB_RECURSE HDRS_CLIENT     src/client/*.h*)
file(GLOB_RECURSE HDRS_COMMON     src/common/*.h*)
file(GLOB_RECURSE HDRS_SERVER     src/server/*.h*)
file(GLOB_RECURSE HDRS_TEST       src/tests/*.h*)
file(GLOB_RECURSE HDRS_TRDL       src/trdl/*.h*)

set(ALL_SRCS
    ${SRCS_ARDUINO}
    ${SRCS_CLIENT}
    ${SRCS_COMMON}
    ${SRCS_SERVER}
    ${SRCS_TEST}
    ${SRCS_TRDL}
)

set(TEST_ALL_SRCS
    ${SRCS_COMMON}
    ${SRCS_TRDL}
    ${SRCS_CLIENT}
    ${SRCS_SERVER}
    ${SRCS_TEST}
)

set(ARDUINO_ALL_SRCS_AND_HDRS
  ${INO_ARDUINO}
  ${HDRS_ARDUINO}
  ${HDRS_COMMON}
  ${HDRS_TRDL}
  ${SRCS_ARDUINO}
  ${SRCS_COMMON}
  ${SRCS_TRDL}
)

# ------------------------------------------------------------
# Test executable
# ------------------------------------------------------------

add_executable(doctest ${TEST_ALL_SRCS})

set_target_properties(doctest PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test
)

add_custom_target(
    run-tests
    COMMAND $<TARGET_FILE:doctest>
    DEPENDS doctest
    USES_TERMINAL
)

# ------------------------------------------------------------
# Tooling targets (clang-tidy, cppcheck, format)
# ------------------------------------------------------------

find_program(CLANG_TIDY clang-tidy)
find_program(CPPCHECK cppcheck)
find_program(CLANG_FORMAT clang-format)

if(CLANG_TIDY)
    add_custom_target(clang-tidy
        COMMENT "clang-tidy..."
        COMMAND ${CLANG_TIDY}
            -p=${CMAKE_BINARY_DIR}
            ${ALL_SRCS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        USES_TERMINAL
    )
endif()

if(CPPCHECK)
    add_custom_target(cppcheck
        COMMENT "cppcheck..."
        COMMAND ${CPPCHECK}
            --project=${CMAKE_BINARY_DIR}/compile_commands.json
            --enable=all
            --inline-suppr
            --suppressions-list=${CMAKE_SOURCE_DIR}/.suppress.cppcheck
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        USES_TERMINAL
    )
endif()

if(CLANG_FORMAT)
    add_custom_target(format
        COMMENT "clang-format..."
        COMMAND ${CLANG_FORMAT} -i ${ALL_SRCS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    add_custom_target(format-check
        COMMENT "clang-format (just checking)..."
        COMMAND ${CLANG_FORMAT} --dry-run --Werror ${ALL_SRCS} || true
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        USES_TERMINAL
    )
endif()


add_custom_target(check)
if(CLANG_TIDY)
    add_dependencies(check clang-tidy)
endif()
if(CPPCHECK)
    add_dependencies(check cppcheck)
endif()
if(CLANG_FORMAT)
    add_dependencies(check format-check)
endif()

# ------------------------------------------------------------
# Arduino artifact copy (mirrors your .ino rule)
# ------------------------------------------------------------

add_custom_target(arduino
    COMMAND ${CMAKE_COMMAND} -E make_directory
        ${CMAKE_BINARY_DIR}/arduino/trdl
    COMMAND ${CMAKE_COMMAND} -E copy
        ${ARDUINO_ALL_SRCS_AND_HDRS}
        ${CMAKE_BINARY_DIR}/arduino/trdl
)
