#
# This file is managed by Puppet. Local edits will be lost.
#

alias hdo-transcripts='cd <%= @transcripts_root %>'
alias hdo-transcripts-app-tail='tail -500f <%= @app_log %>'
alias hdo-transcripts-indexer-tail='tail -500f <%= @transcripts_log %>'