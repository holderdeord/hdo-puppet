#!/bin/bash

[ ! -n "$1" ] && exit 1

SERVER=$1
shift
ARGS=$*

PUPPET_TMP=/tmp/hdo-puppet-rsync

rsync -a --delete puppet "${SERVER}:${PUPPET_TMP}"
ssh -t $SERVER "sudo puppet apply --modulepath=${PUPPET_TMP}/puppet/modules/ ${PUPPET_TMP}/puppet/site.pp ${ARGS}"