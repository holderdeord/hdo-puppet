#!/bin/bash

set -e

ROOT=$(dirname $0)/../

if [[ -z "$DEPLOY_ONLY"  ]]; then
  vagrant destroy && vagrant up || exit 1
  deploy_command="deploy:setup deploy:cold"
else
  deploy_command="deploy:setup deploy:migrations"
fi

echo "Password is 'vagrant'" &&
cat ~/.ssh/id_*.pub | ssh -p 2222 vagrant@localhost "cat > ./key; sudo mkdir -p /home/hdo/.ssh; sudo mv ./key /home/hdo/.ssh/authorized_keys; sudo chown -R hdo:hdo /home/hdo/.ssh" && \
    cd "${ROOT}/../hdo-site" && \
    bundle install && \
    cap vagrant ${deploy_command} && \
    cd -
