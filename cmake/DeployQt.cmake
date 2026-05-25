# Qt deployment for release builds (macOS .app bundle).
if(NOT APPLE OR NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    return()
endif()

find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${Qt6_DIR}/../../../bin" "${Qt6_DIR}/../../bin")
if(NOT MACDEPLOYQT_EXECUTABLE)
    message(STATUS "macdeployqt not found; skip post-build deploy (use scripts/package-macos.sh)")
    return()
endif()

set(_torrin_qml_dir "${CMAKE_SOURCE_DIR}/src/app/qml")
add_custom_command(
    TARGET torrin
    POST_BUILD
    COMMAND "${MACDEPLOYQT_EXECUTABLE}"
            "$<TARGET_BUNDLE_DIR:torrin>"
            -always-overwrite
            -qmldir="${_torrin_qml_dir}"
    COMMENT "Running macdeployqt on Torrin.app"
)
