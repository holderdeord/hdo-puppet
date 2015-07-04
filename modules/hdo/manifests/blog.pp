class hdo::blog(
  $server_name = $::fqdn,
  $drafts      = false,
  $ssl         = true,
  $restrict    = false,
) {
  include hdo::common
  include hdo::params

  $blog_root = "${hdo::params::webapp_root}/blog"

  exec { 'clone hdo-blog':
    command => "git clone git://github.com/holderdeord/hdo-blog ${blog_root}",
    user    => hdo,
    creates => $blog_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'bundle hdo-blog':
    command => "bash -l -c 'bundle install --deployment'",
    cwd     => $blog_root,
    user    => hdo,
    require => Exec['clone hdo-blog']
  }

  $base_command = 'bundle exec jekyll build'

  if ($drafts) {
    $build_command = "${base_command} --drafts"
  } else {
    $build_command = $base_command
  }

  exec { 'build hdo-blog':
    command => "bash -l -c '${build_command}'",
    user    => hdo,
    cwd     => $blog_root,
    require => Exec['bundle hdo-blog']
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': }
  }

  file { "${passenger::nginx::sites_dir}/blog-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-blog-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}
