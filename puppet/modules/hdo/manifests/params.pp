class hdo::params {
  $user                     = 'hdo'
  $group                    = 'adm'

  $webapp_root              = '/webapps'
  $files_root               = "${webapp_root}/files"
  $deploy_root              = "${webapp_root}/hdo-site"
  $app_root                 = "${deploy_root}/current"
  $public_dir               = "${app_root}/public"

  $unicorn_conf             = '/etc/unicorn.hdo.conf'

  $unicorn_run_dir          = '/var/run/unicorn'
  $unicorn_log_dir          = '/var/log/unicorn'

  $unicorn_socket           = "${unicorn_run_dir}/hdo.sock"
  $unicorn_pid              = "${unicorn_run_dir}/hdo.pid"
  $unicorn_log              = "${unicorn_log_dir}/hdo.log"

  $unicorn_worker_processes = '4'
}