#!/bin/bash

ROOT=$(dirname $0)/..

is_our_module () {
  local path=`basename "${1}"`
  local not_ours=( "apache" "firewall" "postgresql" "stdlib" "logrotate" )
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
  if is_our_module "${mod}"
  then
    echo -n "checking `basename ${mod}`..."

    puppet-lint --log-format "%{fullpath}:%{linenumber} %{KIND} %{message}" \
      --no-documentation-check \
      --no-80chars-check \
      --no-class_inherits_from_params_class-check \
      --fail-on-warnings \
      "${mod}"

    ret=$?

    if [[ "${ret}" == "0" ]]; then
      echo "ok"
    else
      echo "failed"
    fi

    [[ "${code}" != "1" ]] && code="${ret}"
  fi
done

exit "${code}"
