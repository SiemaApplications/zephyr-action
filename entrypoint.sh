#!/bin/bash
MANIFESTDIR=${INPUT_MANIFESTDIR:?INPUT_MANIFESTDIR must be specified}
INIT=${INPUT_INIT:-false}
UPDATE=${INPUT_UPDATE:-false}

if [ "${INIT}" = "true" ]; then
    west init -l ${MANIFESTDIR}
fi

if [ "${UPDATE}" = "true" ]; then
    west update
fi
