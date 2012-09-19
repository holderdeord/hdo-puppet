#!/bin/sh

set -e
set -x

PDIR="$(dirname $0)/.."

(cd $PDIR ; git submodule update --init)

puppet apply --modulepath=${PDIR}/puppet/modules/ ${PDIR}/puppet/site.pp "$*"
