#
# This file is managed by Puppet. Local edits will be lost.
#

alias hdo-current='cd <%= scope.lookupvar("hdo::params::app_root") %>'
alias hdo-tail='tail -500f <%= scope.lookupvar("hdo::params::app_root") %>/log/production.log'
alias hdo-console='cd <%= scope.lookupvar("hdo::params::app_root") && RAILS_ENV=production bundle exec rails console'