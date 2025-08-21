cmake_minimum_required(VERSION 3.5)
project(psxsdk C ASM)

if(DEFINED PSX)
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/libs libs)
endif()

if(NOT DEFINED PSX)
    set(CPACK_PACKAGE_NAME "psxsdk")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_LIST_DIR}/license.txt")
    set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_LIST_DIR}/README.md")
    set(CPACK_PACKAGE_CONTACT "Nathan-J. Hirschauer <nathanhi@deepserve.info>")
    #set(CPACK_GENERATOR "RPM;DEB;TGZ;STGZ")
    #set(CPACK_SOURCE_GENERATOR "RPM;TGZ;STGZ")
    set(CPACK_GENERATOR "STGZ")
    set(CPACK_SOURCE_GENERATOR "STGZ")
    set(CPACK_IGNORE_FILES "/\.git/;\.swp\$;\.#;/#")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "PSX SDK built using CMake")
    set(CPACK_PACKAGE_NAME "psxsdk")
    set(CPACK_PACKAGE_RELOCATABLE "true")
    set(CPACK_PACKAGE_VENDOR "psxsdk project")
    set(CPACK_RPM_PACKAGE_SOURCES "ON")
    set(CPACK_SET_DESTDIR "OFF")
    set(CPACK_SOURCE_IGNORE_FILES "/\.git/;\.swp\$;\.#;/#")
    include(CPack)

    # GCC Toolchain
    add_subdirectory(toolchain toolchain)

    # Host tools
    add_subdirectory(tools tools)

    include(ExternalProject)
    ExternalProject_Get_Property(gcc INSTALL_DIR)

    ExternalProject_Add(psxsdk
        SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}
        DEPENDS gcc
        BUILD_ALWAYS TRUE
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}/
                   -DCMAKE_MODULE_PATH:PATH=${CMAKE_CURRENT_LIST_DIR}/toolchain/share/cmake/Modules
                   -DCMAKE_SYSROOT:PATH=${INSTALL_DIR}
                   -DCMAKE_SYSTEM_NAME:STRING=psx
    )
endif()