cmake_minimum_required(VERSION 3.24)

# vcpkg LibtorrentRasterbar -> FindBoost; default OLD until Boost ships CONFIG-only.
if(POLICY CMP0167)
    cmake_policy(SET CMP0167 OLD)
endif()

project(
    torrin
    VERSION 1.0.0
    DESCRIPTION "BitTorrent client for macOS, Windows, and Linux"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

option(TORRIN_BUILD_TESTS "Build unit tests" ON)
option(TORRIN_ENABLE_SANITIZERS "Enable ASan/UBSan" OFF)

if(TORRIN_ENABLE_SANITIZERS AND CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()

add_subdirectory(src)
if(TORRIN_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
