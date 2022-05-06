#!/bin/sh -e
# If github action is using cache, the restored files are owned by a different
# user id/group than the one running the image.  In that case the west command
# reading manifest would fail
# https://github.com/zephyrproject-rtos/west/issues/579
chown $(id -u):$(id -g) -R * .*
