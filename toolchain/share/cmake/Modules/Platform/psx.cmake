include_guard(GLOBAL)

set(PSX 1 CACHE INTERNAL "" FORCE)

# Custom system `psx` for CMake
set(CMAKE_SYSTEM_PROCESSOR "mips")
set(CMAKE_SYSTEM_NAME "psx")
set(CMAKE_SYSTEM_VERSION "0")
set(CMAKE_CROSS_COMPILING TRUE)
set(CMAKE_EXECUTABLE_SUFFIX ".exe")

# Toolchain prefix
set(CMAKE_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/../../../.." CACHE PATH "sysroot for psxsdk toolchain")

# Tool names
set(CMAKE_C_COMPILER "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-gcc" CACHE FILEPATH "C compiler" FORCE)
set(CMAKE_CXX_COMPILER "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-cpp" CACHE FILEPATH "C++ compiler" FORCE)
set(CMAKE_ASM_COMPILER "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-gcc" CACHE FILEPATH "assembler" FORCE)
set(CMAKE_ADDR2LINE "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-addr2line" CACHE FILEPATH "" FORCE)
set(CMAKE_AR "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-ar" CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER_AR "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-ar" CACHE FILEPATH "" FORCE)
set(CMAKE_LINKER "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-ld" CACHE FILEPATH "" FORCE)
set(CMAKE_NM "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-nm" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-objcopy" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJDUMP "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-objdump" CACHE FILEPATH "" FORCE)
set(CMAKE_READELF "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-readelf" CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-strip" CACHE FILEPATH "" FORCE)
set(CMAKE_SIZE_UTIL "${CMAKE_SYSROOT}/bin/mipsel-unknown-elf-size" CACHE FILEPATH "" FORCE)

# Compiler Flags
SET(PSX_COMMON_C_FLAGS "-fno-builtin -mno-gpopt -nostdlib -msoft-float -march=mips1")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${PSX_COMMON_C_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PSX_COMMON_C_FLAGS}" CACHE STRING "" FORCE)

# Specify search path for compiler
set(CMAKE_C_COMPILER_TARGET "mipsel-unknown-elf" CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER_TARGET "mipsel-unknown-elf" CACHE FILEPATH "" FORCE)
set(CMAKE_SYSTEM_PROGRAM_PATH "${CMAKE_SYSROOT}/bin" CACHE PATH "" FORCE)

# Currently no shared library support
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)
set(BUILD_SHARED_LIBS FALSE)

file(GLOB mipsel_prefix_path "${CMAKE_SYSROOT}/lib/gcc/mipsel-unknown-elf/*")
# Common include path for psx projects
set(CMAKE_SYSTEM_INCLUDE_PATH "${CMAKE_CURRENT_LIST_DIR}/include")

# Common library path
foreach(e CMAKE_SYSTEM_LIBRARY_PATH CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES)
    set(e "${mipsel_prefix_path}/lib")
endforeach()

# Use custom linker script
file(GLOB psx_ldscript "${CMAKE_SYSROOT}/lib/gcc/mipsel-unknown-elf/*/psx.ld")
if(EXISTS "${mipsel_prefix_path}/psx.ld")
    add_link_options("-T${psx_ldscript}")
else()
    message(WARNING "Unable to locate PSX SDK linker script")
endif()

# Predefine region
set(PSX_REGION "EUR" CACHE STRING "Region of resulting binary")
set(PSX_REGION_VALUES "EUR;JAP;USA" CACHE INTERNAL "List of possible values for the PSX_REGION cache variable")
set_property(CACHE PSX_REGION PROPERTY STRINGS ${PSX_REGION_VALUES})

set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES "PSX_REGION;CMAKE_SYSTEM_INCLUDE_PATH;CMAKE_SYSTEM_LIBRARY_PATH;CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES")