#
# This file is managed by Puppet. Local edits will be lost.
#

alias hdo-current='cd <%= scope.lookupvar("hdo::params::app_root") %>'
alias hdo-tail='tail -500f <%= scope.lookupvar("hdo::params::app_root") %>/log/<%= scope.lookupvar("hdo::params::enviroment") %>.log'
alias hdo-console='cd <%= scope.lookupvar("hdo::params::app_root") %> && RAILS_ENV=<%= scope.lookupvar("hdo::params::environment") %> bundle exec rails console'