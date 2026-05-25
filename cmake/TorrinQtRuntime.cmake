# Qt image-format plugins and plugin paths (PNG for Quick Controls style assets).
function(torrin_configure_qt_runtime target)
    if(NOT TARGET ${target})
        return()
    endif()

    if(TARGET Qt6::QPNGPlugin)
        target_link_libraries(${target} PRIVATE Qt6::QPNGPlugin)
    endif()

    if(APPLE AND CMAKE_PREFIX_PATH)
        foreach(prefix IN LISTS CMAKE_PREFIX_PATH)
            set(_qt_plugins "${prefix}/Qt6/plugins")
            if(EXISTS "${_qt_plugins}/imageformats")
                target_compile_definitions(${target} PRIVATE
                    TORRIN_QT_PLUGINS_DIR="${_qt_plugins}")
                break()
            endif()
        endforeach()
    endif()
endfunction()
