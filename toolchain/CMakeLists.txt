include(ExternalProject)
include(ProcessorCount)
ProcessorCount(N)

set(TOOLCHAIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/toolchain")
message(STATUS "TOOLCHAIN_DIR: ${TOOLCHAIN_DIR}")
ExternalProject_Add(binutils
                    URL                 https://sourceware.org/pub/binutils/releases/binutils-2.45.tar.xz
                    URL_HASH            SHA256=c50c0e7f9cb188980e2cc97e4537626b1672441815587f1eab69d2a1bfbef5d2
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --target=mipsel-unknown-elf --with-float=soft --enable-lto --enable-static --disable-shared
                    BUILD_COMMAND       make -j${N}
                    INSTALL_COMMAND     make install
)

ExternalProject_Add(m4
                    URL                 https://ftp.gnu.org/gnu/m4/m4-1.4.20.tar.xz
                    URL_HASH            SHA256=e236ea3a1ccf5f6c270b1c4bb60726f371fa49459a8eaaebc90b216b328daf2b
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
                    URL                 https://www.mpfr.org/mpfr-current/mpfr-4.2.2.tar.xz
                    URL_HASH            SHA256=b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01
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

set(gcc_version "15.2.0")
set(gcc_version "${gcc_version}" PARENT_SCOPE)
ExternalProject_Add(gcc
                    DEPENDS             binutils gmp mpfr mpc
                    URL                 https://fosszone.csd.auth.gr/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz
                    URL_HASH            SHA256=438fd996826b0c82485a29da03a72d71d6e3541a83ec702df4271f6fe025d24e
                    INSTALL_DIR         ${TOOLCHAIN_DIR}
                    CONFIGURE_COMMAND   LD_LIBRARY_PATH=<INSTALL_DIR>/lib <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --disable-libada --disable-libssp --target=mipsel-unknown-elf --with-float=soft --with-gmp=<INSTALL_DIR> --with-gmp-lib=<INSTALL_DIR>/lib/libgmp.a --with-mpfr=<INSTALL_DIR> --with-mpfr-lib=<INSTALL_DIR>/lib/libmpfr.a --with-mpc=<INSTALL_DIR> --with-mpc-lib=<INSTALL_DIR>/lib/libmpc.a --disable-libquadmath --enable-stage1-languages=c --enable-languages=c --enable-lto --enable-static --disable-shared
                    BUILD_COMMAND       LD_LIBRARY_PATH=<INSTALL_DIR>/lib make -j${N}
                    INSTALL_COMMAND     LD_LIBRARY_PATH=<INSTALL_DIR>/lib make install
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