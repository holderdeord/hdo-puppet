class passenger::params {
  $version               = '3.0.17'
  $root                  = "/var/lib/gems/1.9.1/gems/passenger-${version}"
  $ruby                  = '/usr/bin/ruby1.9.1'
  $min_instances         = 3
  $max_pool_size         = 10
  $max_instances_per_app = 10 # only running one app
  $pool_idle_time        = 300
}