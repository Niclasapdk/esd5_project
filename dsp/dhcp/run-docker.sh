#!/bin/sh

docker run --net host -it --rm --init -v "$(pwd)/data":/data networkboot/dhcpd enp0s31f6
