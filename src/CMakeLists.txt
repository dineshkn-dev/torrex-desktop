find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 QuickDialogs2)
qt_policy(SET QTP0004 NEW)

find_package(LibtorrentRasterbar CONFIG REQUIRED)

add_subdirectory(core)
add_subdirectory(models)
add_subdirectory(app)
