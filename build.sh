#!/bin/bash

set -xe

source ../env.sh

rm -rf .build
rm -f fuel-plugin-tesora-dbaas-*.rpm

sed -i "s/^version:.*/version: \'$DBAAS_VERSION_LONG\'/" metadata.yaml

pushd ..
fpb --debug --build fuel-plugin-tesora-dbaas
popd
