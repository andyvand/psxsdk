function(_add_lib target)
    cmake_parse_arguments(TGT "" "DIRECTORY" "" ${ARGN})

    add_library(${target})
    add_library(psx::${target} ALIAS ${target})
    install(
        TARGETS ${target}
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
    )
    install(
        DIRECTORY ${TGT_DIRECTORY}/include/
        DESTINATION include
    )

    file(GLOB_RECURSE sources CONFIGURE_DEPENDS ${TGT_DIRECTORY}/src/*)
    target_sources(${target}
        PRIVATE
            ${sources}
    )
    target_include_directories(${target} PUBLIC ${TGT_DIRECTORY}/include)
endfunction()

if(DEFINED PSX)
    # PSX specific startup code
    add_library(start OBJECT start.s)
    set_property(TARGET start PROPERTY OUTPUT_NAME "start.o")
    add_library(psx::start ALIAS start)
    install(
        FILES
            $<TARGET_OBJECTS:start>
        DESTINATION lib
        RENAME "start.o"
    )

    _add_lib(m
        DIRECTORY libm
    )

    # PSX core "libc"/stdlib
    _add_lib(psx
        DIRECTORY libpsx
    )
    target_link_libraries(psx PRIVATE psx::start psx::m)

    _add_lib(adpcm
        DIRECTORY libadpcm
    )
    target_link_libraries(adpcm
        PRIVATE
            psx::m
            psx::psx
    )

    # Huffmann decompression algorithm
    _add_lib(huff
        DIRECTORY libhuff
    )
    target_link_libraries(huff
        PRIVATE
            psx::psx
    )
endif()

# .mod playback library
_add_lib(modplay
    DIRECTORY libmodplay
)
target_compile_definitions(modplay
    PRIVATE
        $<$<NOT:$<PLATFORM_ID:psx>>:NO_PSX_LIB>
)
target_link_libraries(modplay
    PRIVATE
        $<$<PLATFORM_ID:psx>:psx::psx>
        # TODO: Unify tools/adpcm and libs/libadpcm
        $<$<STREQUAL:${CMAKE_SYSTEM_NAME},psx>:psx::adpcm>
)