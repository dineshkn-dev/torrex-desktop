find_package(Libtorrent CONFIG REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

add_subdirectory(core)
add_subdirectory(models)
add_subdirectory(app)
