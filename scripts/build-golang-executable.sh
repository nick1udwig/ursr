#!/bin/bash

# Build Golang middleman into exectuables.

usage_string="Usage: ./scripts/build-golang-executable.sh semantic-version(e.g.'1.0.0')"

# Parse args.
if [ $# -ne 1 ]; then
    echo "$usage_string"
    exit 1
fi
version=$1

# Script expects to be run from top-level ursr directory.
current_dir=$(basename $(pwd))
if [ "$current_dir" != "ursr" ]; then
    echo "$usage_string"
    echo ""
    echo "This script expects to be run from top-level ursr directory."
    exit 2
fi

cd go

for os in darwin linux; do
    for arch in amd64; do
        echo "Packaging ${os}-${arch}..."

        mkdir ursr-go-v${version}-${os}-${arch}.tar.gz
        env GOOS=$os GOARCH=$arch go build -ldflags='-s -w' -o ursr-go-v${version}-${os}-${arch}/ursr-go cmd/main.go
        cp ../README.md ursr-go-v${version}-${os}-${arch}
        tar zcf ursr-go-v${version}-${os}-${arch}.tar.gz ursr-go-v${version}-${os}-${arch}
        rm -rf ursr-go-v${version}-${os}-${arch}
    done
done
echo "Done."
