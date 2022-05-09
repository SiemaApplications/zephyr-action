#!/bin/sh -e
MANIFESTDIR="${INPUT_MANIFESTDIR:?INPUT_MANIFESTDIR must be specified}"
INIT="${INPUT_INIT:-false}"
UPDATE="${INPUT_UPDATE:-false}"
TWISTER="${INPUT_TWISTER:-false}"
BUILD="${INPUT_BUILD:-false}"
SIGN="${INPUT_SIGN:-false}"

trust_git_repos()
{
    for d in $(west list | tail +2 | awk '{print $2}'); do
        git config --global --add safe.directory $(pwd)/${d}
    done
}

if [ "${INIT}" = "true" ]; then
    set -x
    west init -l ${MANIFESTDIR}
    set +x
fi

if [ "${UPDATE}" = "true" ]; then
    # If running from github action and zephyr directory is already present it means there was a
    # cache hit. In that case file ownership does not match between steps running directly on github
    # runner (docker user) and user running this script from github action step (root).
    # It is therefore necessary trust each repos in the cache.
    set -x
    if [ ! -z "${GITHUB_WORKSPACE}" -a -d zephyr/ ]; then
        trust_git_repos
    fi
    UPDATE_EXTRA_ARGS=${INPUT_UPDATE_EXTRA_ARGS}
    west update --narrow --fetch-opt=--depth=1 ${UPDATE_EXTRA_ARGS}
    set +x
fi

if [ "${BUILD}" = "true" ]; then
    BUILD_BOARD="${INPUT_BUILD_BOARD:?Missing board target name}"
    BUILD_APP_DIR="${INPUT_BUILD_APP_DIR:?Missing application directory}"
    BUILD_DIR="${INPUT_BUILD_DIR:-build/${BUILD_BOARD}/$(basename ${BUILD_APP_DIR})}"
    CMAKE_EXTRA_ARGS="${INPUT_CMAKE_EXTRA_ARGS}"
    set -x
    west build -p auto -b "${BUILD_BOARD}" -d "${BUILD_DIR}" "${BUILD_APP_DIR}" \
        -- ${CMAKE_EXTRA_ARGS}
    set +x

fi

if [ "${TWISTER}" = "true" ]; then
    TWISTER_APP_DIR="${INPUT_TWISTER_APP_DIR:?Missing application directory}"
    if [ ! -z "${INPUT_TWISTER_BOARD_ROOT}" ]; then
        if [ -d ${INPUT_TWISTER_BOARD_ROOT} ]; then
            TWISTER_ARGS="-A ${INPUT_TWISTER_BOARD_ROOT}"
        else
            echo "Error: INPUT_TWISTER_BOARD_ROOT: invalid directory ${INPUT_TWISTER_BOARD_ROOT}"
            exit 1
        fi
    fi

    if [ ! -z ${INPUT_TWISTER_BUILD_DIR} ]; then
        TWISTER_ARGS="${TWISTER_ARGS} -O ${INPUT_TWISTER_BUILD_DIR}"
    fi

    if [ ! -z ${INPUT_TWISTER_BOARD} ]; then
        TWISTER_ARGS="${TWISTER_ARGS} -p ${INPUT_TWISTER_BOARD}"
    fi

    set -x
    ./zephyr/scripts/twister ${TWISTER_ARGS} \
        -T "${TWISTER_APP_DIR}" \
        ${INPUT_TWISTER_EXTRA_ARGS}
    set +x
fi

# Signing manifest shall contain on each line path of the application to sign
# and its version separated by a ';':
# path/to/app; 1.0
# path/to/app2; 1.1
if [ "${SIGN}" = "true" ]; then
    SIGN_KEY="${INPUT_SIGN_KEY:-bootloader/mcuboot/root-rsa-2048.pem}"
    SIGN_ALIGNMENT="${INPUT_SIGN_ALIGNMENT:-32}"
    SIGN_MANIFEST="${INPUT_SIGN_MANIFEST:?Missing signing manifest}"
    if [ ! -f ${SIGN_MANIFEST} ]; then
        echo "Error: INPUT_SIGN_MANIFEST: invalid file ${SIGN_MANIFEST}"
        exit 1
    fi
    while read l; do
        APP=$(echo ${l} | cut -d';' -f 1)
        VERSION=$(echo ${l} | cut -d';' -f 2)
        if [ ! -d "${APP}" ]; then
            echo "Error: ${APP} invalid directory"
            exit 1
        fi
        set -x
        west --verbose sign -d ${APP} -t imgtool \
            -p bootloader/mcuboot/scripts/imgtool.py \
            -- --key ${SIGN_KEY} --align ${SIGN_ALIGNMENT} --pad \
            --version ${VERSION}
        set +x
    done <${SIGN_MANIFEST}
fi
