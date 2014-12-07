class hdo::blog(
  $listen      = 80,
  $server_name = $::fqdn,
  $drafts      = false
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

  $base_command = 'bundle exec jekyll build --lsi'

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

  class { 'passenger::nginx': port => $listen }

  file { "${passenger::nginx::sites_dir}/blog-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-blog-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}
