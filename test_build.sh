#!/bin/sh -e

echo "Building Kenosis packages in isolated Docker container..."

docker run --rm -v "$(pwd)/repo:/repo" -w /build alpine:3.20 sh -c '
    set -e

    # Install host build dependencies
    apk add --no-cache git make gcc musl-dev perl curl ca-certificates xz

    # Setup KISS
    git clone https://github.com/kiss-community/kiss /kiss
    export PATH="/kiss:$PATH"
    export KISS_ROOT="/"
    export KISS_PATH="/repo"
    export KISS_PROMPT=0
    export LOGNAME=root
    export USER=root

    # Bootstrap qbe and cproc to use as compiler
    kiss build qbe
    kiss install qbe

    kiss build cproc
    kiss install cproc

    # Now use cproc for the rest of the packages
    export CC=cproc

    kiss build musl
    kiss build linux-headers
    kiss build sbase
    kiss build ubase
    kiss build sinit
    kiss build daemontools-encore
    kiss build yash
    kiss build vis
    kiss build dvtm
    kiss build abduco

    echo "All packages built successfully!"
'
