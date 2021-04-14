# Zephyr Build
This action is used to manage `west` repository. (init, update, build, ...)

# Usage
```yaml
- uses: SiemaApplications/zephyr-action@v1
  with:
    manifestdir: 'out-of-tree-manifest-repository'
    init: 'true'
    update: 'true'
    twister: 'true'
    twister_app_dir: 'out-of-tree-manifest-repository/app1'
    twister_board: 'nucleo_h743zi'
```

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
The `entrypoint.sh` script is executed and the above command will fail due to missing environement variables not being defined. Pass the appropriates variable with `-e VAR=value` based on what you want to do.
