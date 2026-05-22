add_library(torrex_core STATIC
    session_manager.cpp
)

add_library(torrex::core ALIAS torrex_core)

target_include_directories(torrex_core
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(torrex_core
    PUBLIC
        Libtorrent::torrent-rasterbar
)

target_compile_features(torrex_core PUBLIC cxx_std_20)
