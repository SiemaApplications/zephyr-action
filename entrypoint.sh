#!/bin/bash -e
MANIFESTDIR=${INPUT_MANIFESTDIR:?INPUT_MANIFESTDIR must be specified}
INIT=${INPUT_INIT:-false}
UPDATE=${INPUT_UPDATE:-false}
TWISTER=${INPUT_TWISTER:-false}


if [ "${INIT}" = "true" ]; then
    west init -l ${MANIFESTDIR}
fi

if [ "${UPDATE}" = "true" ]; then
    west update
fi

if [ "${TWISTER}" = "true" ]; then
    TWISTER_BOARD=${INPUT_TWISTER_BOARD:?Missing board target name}
    TWISTER_APP_DIR=${INPUT_TWISTER_APP_DIR:?Missing application directory}
    if [ ! -z "${INPUT_TWISTER_BOARD_ROOT}" ]; then
        if [ -d ${INPUT_TWISTER_BOARD_ROOT} ]; then
            TWISTER_BOARD_ROOT_ARG="-A ${INPUT_TWISTER_BOARD_ROOT}"
        else
            echo "Error: INPUT_TWISTER_BOARD_ROOT: invalid directory ${INPUT_TWISTER_BOARD_ROOT}"
            exit 1
        fi
    fi
    ./zephyr/scripts/twister -p ${TWISTER_BOARD} ${TWISTER_BOARD_ROOT_ARG} \
        -T ${TWISTER_APP_DIR}

fi
