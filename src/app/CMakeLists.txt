qt_standard_project_setup()

if(POLICY QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()

qt_add_executable(torrex
    main.cpp
    app_controller.cpp
)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(torrex
    URI Torrex
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/ThemedPanel.qml
        qml/ThemedProgressBar.qml
        qml/ConfirmPopup.qml
        qml/NotificationBanner.qml
        qml/SettingsDialog.qml
        qml/TorrentDetail.qml
        qml/TorrentListPane.qml
        qml/TorrentRow.qml
        qml/TgIconButton.qml
        qml/TgButton.qml
        qml/TgTextField.qml
        qml/FilterChip.qml
        qml/EmptyState.qml
        qml/DetailStat.qml
        qml/DetailStatRow.qml
        qml/DetailCard.qml
        qml/TorrentOverviewPane.qml
        qml/TorrentFilesPane.qml
        qml/TgTabButton.qml
)

target_link_libraries(torrex
    PRIVATE
        torrex_models
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
)

target_include_directories(torrex
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${PROJECT_SOURCE_DIR}/src/models
)

target_compile_features(torrex PRIVATE cxx_std_20)

# QML module creates a Torrex/ directory beside the target; keep the binary out of src/app/
set_target_properties(torrex PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if(APPLE)
    set_target_properties(torrex PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_GUI_IDENTIFIER org.torrex.desktop
        MACOSX_BUNDLE_BUNDLE_NAME Torrex
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/cmake/MacOSXBundleInfo.plist.in"
    )
    # Shell launcher at bin/torrex → torrex.app (avoids stale flat Mach-O with old QML).
    add_custom_command(TARGET torrex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_SOURCE_DIR}/scripts/torrex-dev-launcher.sh"
            "${CMAKE_BINARY_DIR}/bin/torrex"
        COMMAND chmod a+x "${CMAKE_BINARY_DIR}/bin/torrex"
        COMMENT "Install dev launcher script at bin/torrex"
    )
endif()

if(WIN32)
    set_target_properties(torrex PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

include(${CMAKE_SOURCE_DIR}/cmake/DeployQt.cmake OPTIONAL)
