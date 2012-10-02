node 'default' {
  #include hdo::backend::apache
  #include hdo::database
  #include munin::master
  #include munin::node
  include elasticsearch
}

node 'beta.holderdeord.no' {
  include hdo::backend::apache
  include hdo::database
}


#
# testing azure
#

node 'hdo01.cloudapp.net' {
  include hdo::backend::nginx
  include hdo::database
}

node 'hdo02.cloudapp.net' {
  include hdo::backend::apache
  include hdo::database
}

node 'hdo-staging.nuug.no' {
  include hdo::backend::apache
  include hdo::database
}
