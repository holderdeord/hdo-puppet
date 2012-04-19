#!/bin/bash

export VAGRANT=1 # important.

if [[ -z "$DEPLOY_ONLY"  ]]; then
  vagrant destroy && vagrant up 
fi

echo "Password is 'vagrant'" &&
(cat ~/.ssh/id_*.pub | ssh -p 2222 vagrant@localhost "cat > ./key; sudo mkdir /home/hdo/.ssh; sudo mv ./key /home/hdo/.ssh/authorized_keys; sudo chown -R hdo:hdo /home/hdo/.ssh") &&
cd ../hdo-site &&
bundle install &&
cap deploy:setup deploy:migrations
  
    