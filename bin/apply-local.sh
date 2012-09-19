#!/bin/sh

set -e

exec > /var/log/hdo-puppet.log 2>&1

set -x

PDIR="$(dirname $0)/.."

(cd $PDIR ; git submodule update --init)

puppet apply --modulepath=${PDIR}/puppet/modules/ ${PDIR}/puppet/site.pp "$*"
