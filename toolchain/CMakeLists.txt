include(ExternalProject)
include(ProcessorCount)
ProcessorCount(N)

set(TOOLCHAIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/toolchain")
message(STATUS "TOOLCHAIN_DIR: ${TOOLCHAIN_DIR}")
ExternalProject_Add(binutils
                    URL                 https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz
                    URL_HASH            SHA256=f6e4d41fd5fc778b06b7891457b3620da5ecea1006c6a4a41ae998109f85a800
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --target=mipsel-unknown-elf --with-float=soft --enable-lto --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

ExternalProject_Add(m4
                    URL                 http://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz
                    URL_HASH            SHA256=63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

ExternalProject_Add(gmp
                    DEPENDS             m4
                    URL                 https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz
                    URL_HASH            SHA256=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> M4=<INSTALL_DIR>/bin/m4 --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

ExternalProject_Add(mpfr
                    DEPENDS             gmp
                    URL                 https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.xz
                    URL_HASH            SHA256=277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gmp=<INSTALL_DIR> --enable-lto --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

ExternalProject_Add(mpc
                    DEPENDS             gmp mpfr
                    URL                 https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
                    URL_HASH            SHA256=ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gmp=<INSTALL_DIR> --with-mpfr=<INSTALL_DIR> --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

set(gcc_version "13.2.0")
set(gcc_version "${gcc_version}" PARENT_SCOPE)
ExternalProject_Add(gcc
                    DEPENDS             binutils gmp mpfr mpc
                    URL                 http://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz
                    URL_HASH            SHA256=e275e76442a6067341a27f04c5c6b83d8613144004c0413528863dc6b5c743da
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   PATH=<INSTALL_DIR>/bin:$ENV{PATH} LD_LIBRARY_PATH=<INSTALL_DIR>/lib <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --disable-libada --disable-libssp --target=mipsel-unknown-elf --with-float=soft --with-gmp=<INSTALL_DIR> --with-gmp-lib=<INSTALL_DIR>/lib/libgmp.a --with-mpfr=<INSTALL_DIR> --with-mpfr-lib=<INSTALL_DIR>/lib/libmpfr.a --with-mpc=<INSTALL_DIR> --with-mpc-lib=<INSTALL_DIR>/lib/libmpc.a --disable-libquadmath --enable-stage1-languages=c --enable-languages=c --enable-lto --enable-static --disable-shared
                    BUILD_COMMAND       PATH=<INSTALL_DIR>/bin:$ENV{PATH} LD_LIBRARY_PATH=<INSTALL_DIR>/lib make -j${N}
                    INSTALL_COMMAND     PATH=<INSTALL_DIR>/bin:$ENV{PATH} LD_LIBRARY_PATH=<INSTALL_DIR>/lib make install
)

install(
    DIRECTORY "${TOOLCHAIN_DIR}/"
    DESTINATION .
    USE_SOURCE_PERMISSIONS
)

install(
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/share"
    DESTINATION .
    USE_SOURCE_PERMISSIONS
)

install(
    FILES "${CMAKE_CURRENT_LIST_DIR}/psx.ld"
    DESTINATION "lib/gcc/mipsel-unknown-elf/${gcc_version}/"
)

install(
    DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/licenses"
    DESTINATION share
)