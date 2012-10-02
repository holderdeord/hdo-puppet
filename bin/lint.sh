#!/bin/bash

set -e

ROOT=$(dirname $0)/..

is_our_module () {
  local path=`basename "${1}"`
  local not_ours=( "apache" "firewall" "postgresql" "puppetlabs-stdlin" )
  local mod

  for mod in "${not_ours[@]}"
  do
    [[ "${mod}" == "${path}" ]] && return 1
  done

  return 0
}

code=0

for mod in ${ROOT}/puppet/modules/*
do
  echo "${mod}"

  if is_our_module "${mod}"
  then
    puppet-lint --log-format "%{fullpath}:%{linenumber} %{KIND} %{message}" --no-documentation-check --no-80chars-check --fail-on-warnings "${mod}"

    ret=$?
    [[ "${code}" != "1" ]] && code="${ret}"
  fi
done

exit "${code}"
