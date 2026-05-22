qt_standard_project_setup()

qt_add_executable(torrex
    main.cpp
    app_controller.cpp
)

set_source_files_properties(../ui/qml/theme/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(torrex
    URI Torrex
    VERSION 1.0
    QML_FILES
        ../ui/qml/Main.qml
        ../ui/qml/theme/Theme.qml
)

target_link_libraries(torrex
    PRIVATE
        torrex_models
        Qt6::Quick
        Qt6::QuickControls2
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

if(WIN32)
    set_target_properties(torrex PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

include(${CMAKE_SOURCE_DIR}/cmake/DeployQt.cmake OPTIONAL)
