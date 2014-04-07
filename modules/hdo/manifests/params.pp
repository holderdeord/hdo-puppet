class hdo::params {
  $user                  = 'hdo'
  $group                 = 'adm'
  $admin_email           = 'ops@holderdeord.no'

  $webapp_root           = '/webapps'
  $deploy_root           = "${webapp_root}/hdo-site"
  $app_root              = "${deploy_root}/current"
  $home                  = "/home/${user}"

  $environment           = hiera('hdo_environment',        'staging')
  $db_server_password    = hiera('hdo_db_server_password', 'dont-use-this')
  $db_username           = hiera('hdo_db_username',        'hdo')
  $db_password           = hiera('hdo_db_password',        'dont-use-this')
  $secret_token          = hiera('hdo_secret_token',       'e760f5c7ac1a6213b8adf18892a2d5d8d471ecc52fa219e012152290e4c201dc28ce8a9353ce106194e4739dab073d414ad6d259d35bc6cd4c6074ada0aef9d2')

  $hipchat_api_token       = hiera('hipchat_api_token', '')
  $new_relic_license_key   = hiera('new_relic_license_key', '')
  $fastly_api_key          = hiera('fastly_api_key', '')
  $hdo_basic_auth          = hiera('hdo_basic_auth', '')
  $twitter_consumer_key    = hiera('twitter_consumer_key', '')
  $twitter_consumer_secret = hiera('twitter_consumer_secret', '')
}
