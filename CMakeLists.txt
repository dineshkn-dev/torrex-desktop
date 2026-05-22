cmake_minimum_required(VERSION 3.24)

project(
    torrex
    VERSION 0.1.0
    DESCRIPTION "Cross-platform BitTorrent client"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

option(TORREX_BUILD_TESTS "Build unit tests" ON)
option(TORREX_ENABLE_SANITIZERS "Enable ASan/UBSan" OFF)

if(TORREX_ENABLE_SANITIZERS AND CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()

add_subdirectory(src)
if(TORREX_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
