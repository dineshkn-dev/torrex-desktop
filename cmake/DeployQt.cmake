# Post-build Qt deployment (macdeployqt / windeployqt) — expanded in Phase 5.
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${Qt6_DIR}/../../../bin")
    if(MACDEPLOYQT_EXECUTABLE AND APPLE)
        add_custom_command(
            TARGET torrex
            POST_BUILD
            COMMAND "${MACDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE:torrex>" -always-overwrite
            COMMENT "Running macdeployqt"
        )
    endif()
endif()
