find_package(GTest CONFIG REQUIRED)

add_executable(torrin_tests
    core/version_test.cpp
    core/session_manager_test.cpp
    core/add_torrent_test.cpp
    core/torrent_ops_test.cpp
    core/torrent_filter_test.cpp
    core/session_settings_test.cpp
    core/torrent_controls_test.cpp
    core/torrent_preview_test.cpp
)

target_link_libraries(torrin_tests
    PRIVATE
        torrin_core
        GTest::gtest_main
)

target_compile_features(torrin_tests PRIVATE cxx_std_20)

# Core-only tests; global AUTOMOC would warn without any Qt sources.
set_target_properties(torrin_tests PROPERTIES AUTOMOC OFF AUTORCC OFF AUTOUIC OFF)

include(GoogleTest)
gtest_discover_tests(torrin_tests)
