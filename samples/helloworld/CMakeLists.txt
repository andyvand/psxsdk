set(CMAKE_MODULE_PATH "/home/nathanhi/bin/psxsdk/share/cmake/Modules")
set(CMAKE_SYSTEM_NAME psx)

cmake_minimum_required(VERSION 3.5)
project(psxsdk-helloworld C)

add_executable(helloworld helloworld.c)