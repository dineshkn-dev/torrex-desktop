qt_standard_project_setup()

qt_add_executable(torrin
    main.cpp
    app_controller.cpp
)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(torrin
    URI Torrin
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/ThemedPanel.qml
        qml/ThemedProgressBar.qml
        qml/ConfirmPopup.qml
        qml/AddTorrentFilePicker.qml
        qml/MagnetAddDialog.qml
        qml/TorrentAddDialog.qml
        qml/NotificationBanner.qml
        qml/SettingsDialog.qml
        qml/SettingsNumberRow.qml
        qml/AppearanceSettingsSection.qml
        qml/AccentColorSwatch.qml
        qml/TgToggleRow.qml
        qml/TorrentDetail.qml
        qml/TorrentListPane.qml
        qml/TorrentRow.qml
        qml/TgIconButton.qml
        qml/TgSettingsIcon.qml
        qml/TgButton.qml
        qml/TgTextField.qml
        qml/FilterChip.qml
        qml/EmptyState.qml
        qml/DetailStat.qml
        qml/DetailStatRow.qml
        qml/DetailCard.qml
        qml/DetailProgressRing.qml
        qml/DetailMetricTile.qml
        qml/DetailActionChip.qml
        qml/DetailSegmentBar.qml
        qml/DetailSpeedCard.qml
        qml/DetailStatusPill.qml
        qml/TorrentOverviewPane.qml
        qml/TorrentFilesPane.qml
        qml/TgTabButton.qml
        qml/TgSwitch.qml
        qml/TgMenu.qml
        qml/TgMenuSeparator.qml
        qml/TgScrollView.qml
        qml/TgFormScroll.qml
        qml/TgSheet.qml
        qml/TgSheetHeader.qml
        qml/TgSheetFooter.qml
        qml/TgSheetDivider.qml
        qml/TgMenuPicker.qml
        qml/TorrinLogo.qml
)

target_link_libraries(torrin
    PRIVATE
        torrin_models
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::QuickDialogs2
        Qt6::Svg
)

qt_add_resources(torrin "brand"
    PREFIX "/"
    BASE "${CMAKE_SOURCE_DIR}/resources"
    FILES
        "${CMAKE_SOURCE_DIR}/resources/brand/torrin-mark.svg"
        "${CMAKE_SOURCE_DIR}/resources/brand/torrin-app-icon.svg"
)

include(${CMAKE_SOURCE_DIR}/cmake/TorrinQtRuntime.cmake)
torrin_configure_qt_runtime(torrin)

target_include_directories(torrin
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${PROJECT_SOURCE_DIR}/src/models
)

target_compile_features(torrin PRIVATE cxx_std_20)

# QML module creates a Torrin/ directory beside the target; keep the binary out of src/app/
set_target_properties(torrin PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

if(APPLE)
    set(_torrin_icns "${CMAKE_SOURCE_DIR}/resources/macos/Torrin.icns")
    if(EXISTS "${_torrin_icns}")
        set_source_files_properties("${_torrin_icns}" PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
        target_sources(torrin PRIVATE "${_torrin_icns}")
    endif()
    set_target_properties(torrin PROPERTIES
        MACOSX_BUNDLE ON
        MACOSX_BUNDLE_GUI_IDENTIFIER org.torrin.desktop
        MACOSX_BUNDLE_BUNDLE_NAME Torrin
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/cmake/MacOSXBundleInfo.plist.in"
    )
    if(EXISTS "${_torrin_icns}")
        set_target_properties(torrin PROPERTIES MACOSX_BUNDLE_ICON_FILE Torrin.icns)
    endif()
    # Shell launcher at bin/torrin → torrin.app (avoids stale flat Mach-O with old QML).
    add_custom_command(TARGET torrin POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            "${CMAKE_SOURCE_DIR}/scripts/torrin-dev-launcher.sh"
            "${CMAKE_BINARY_DIR}/bin/torrin"
        COMMAND chmod a+x "${CMAKE_BINARY_DIR}/bin/torrin"
        COMMENT "Install dev launcher script at bin/torrin"
    )
endif()

if(WIN32)
    set_target_properties(torrin PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

include(${CMAKE_SOURCE_DIR}/cmake/DeployQt.cmake OPTIONAL)
