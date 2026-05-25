add_library(torrin_models STATIC
    torrent_list_model.cpp
)

add_library(torrin::models ALIAS torrin_models)

target_link_libraries(torrin_models
    PUBLIC
        torrin_core
        Qt6::Core
)

target_include_directories(torrin_models
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_features(torrin_models PUBLIC cxx_std_20)
