find_package(GTest CONFIG REQUIRED)

add_executable(torrex_tests
    core/version_test.cpp
    core/session_manager_test.cpp
)

target_link_libraries(torrex_tests
    PRIVATE
        torrex_core
        GTest::gtest_main
)

target_compile_features(torrex_tests PRIVATE cxx_std_20)

include(GoogleTest)
gtest_discover_tests(torrex_tests)
