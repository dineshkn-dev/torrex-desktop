add_library(torrex_models STATIC
    torrent_list_model.cpp
)

add_library(torrex::models ALIAS torrex_models)

target_link_libraries(torrex_models
    PUBLIC
        torrex_core
        Qt6::Core
)

target_include_directories(torrex_models
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_features(torrex_models PUBLIC cxx_std_20)
