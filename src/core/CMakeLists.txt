add_library(torrin_core STATIC
    session_manager.cpp
    torrent_preview.cpp
    info_hash_key.cpp
)

add_library(torrin::core ALIAS torrin_core)

target_include_directories(torrin_core
    PUBLIC
        ${PROJECT_SOURCE_DIR}/include
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(torrin_core
    PUBLIC
        LibtorrentRasterbar::torrent-rasterbar
)

target_compile_features(torrin_core PUBLIC cxx_std_20)
