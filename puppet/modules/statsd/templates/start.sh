#!/bin/sh

STATSD_BIN=$(which statsd)

if [ ! -x "$STATSD_BIN" ]; then
  echo "Can't find executable statsd in PATH=$PATH"
  exit 1
fi

$STATSD_BIN /etc/statsd/config.js 2>&1 >> /var/log/statsd/statsd.log