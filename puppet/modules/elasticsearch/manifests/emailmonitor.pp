# Cron+email check of ES until we have proper monitoring
class elasticsearch::emailmonitor($ensure = absent) {
  cron { 'elasticsearch-email':
    ensure      => $ensure,
    command     => 'nc -z localhost 9200 >/dev/null 2>&1 || echo "elasticsearch not responding"',
    user        => hdo,
    environment => ['PATH=/usr/local/bin:/usr/bin:/bin', 'MAILTO=ops@holderdeord.no'],
    minute      => '*/5'
  }
}
