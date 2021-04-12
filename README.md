# Zephyr Build
This action is used to manage `west` repository. (init, update, build, ...)

# Usage
TODO


# Use docker image locally
It is possible to use the docker image to use as a development environment.

## Build docker container
Build docker image with a user created with the same uid and gid as user building image.
```
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t build-zephyr .
```

## Start container
Start container with uid/gid of current user.

`src` volume is where sources should be mounted.
```
docker run -it --rm -u $(id -u ${USER}):$(id -g ${USER}) -v <west top dir>:/src build-zephyr
```
