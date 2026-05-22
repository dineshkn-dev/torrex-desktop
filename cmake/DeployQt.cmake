# Qt deployment for release builds (macOS .app bundle).
if(NOT APPLE OR NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    return()
endif()

find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${Qt6_DIR}/../../../bin" "${Qt6_DIR}/../../bin")
if(NOT MACDEPLOYQT_EXECUTABLE)
    message(STATUS "macdeployqt not found; skip post-build deploy (use scripts/package-macos.sh)")
    return()
endif()

set(_torrex_qml_dir "${CMAKE_SOURCE_DIR}/src/app/qml")
add_custom_command(
    TARGET torrex
    POST_BUILD
    COMMAND "${MACDEPLOYQT_EXECUTABLE}"
            "$<TARGET_BUNDLE_DIR:torrex>"
            -always-overwrite
            -qmldir="${_torrex_qml_dir}"
    COMMENT "Running macdeployqt on Torrex.app"
)
