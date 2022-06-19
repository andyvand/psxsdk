#!/bin/bash -ex

PSXSDK_DIR="$(realpath $(dirname "${BASH_SOURCE[0]}"))"
CONTAINER_CMD=""
CONTAINER_CMD_ARGS=""

if command -v docker &>/dev/null; then
    CONTAINER_CMD="docker"
    CONTAINER_CMD_ARGS="-u $(id -u):$(id -g)"
elif command -v podman &>/dev/null; then
    CONTAINER_CMD="podman"
else
    mkdir build || true
    cd build
    cmake ..
    cmake --build . --target package
    exit $?
fi

${CONTAINER_CMD} run --rm \
                     ${CONTAINER_CMD_ARGS} \
                     -v "${PSXSDK_DIR}":"${PSXSDK_DIR}" \
                     -w "${PSXSDK_DIR}" \
                     -it $(docker build -q "${PSXSDK_DIR}/toolchain") \
                     $0 "${@}"