class hdo::params {
  $user               = 'hdo'
  $group              = 'adm'
  $admin_email        = 'ops@holderdeord.no'

  $webapp_root        = '/webapps'
  $files_root         = "${webapp_root}/files"
  $deploy_root        = "${webapp_root}/hdo-site"
  $app_root           = "${deploy_root}/current"
  $public_dir         = "${app_root}/public"

  $environment        = hiera('hdo_environment',        'staging')
  $db_server_password = hiera('hdo_db_server_password', 'dont-use-this')
  $db_username        = hiera('hdo_db_username',        'hdo')
  $db_password        = hiera('hdo_db_password',        'dont-use-this')
}