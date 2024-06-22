#!/bin/sh

cd wheels

FREEBSD_VERSION=$(uname -r | tr '.' '_' | tr '-' '_' | tr '[:upper:]' '[:lower:]')


for file in *freebsd_13_2_release*.whl; do
    mv "$file" "$(echo "$file" | sed "s/13_2_release/${FREEBSD_VERSION}/")"
done

for file in *freebsd_13_2_RELEASE*.whl; do
    mv "$file" "$(echo "$file" | sed "s/13_2_RELEASE/${FREEBSD_VERSION}/")"
done

cd ..
