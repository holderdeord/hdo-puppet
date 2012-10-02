class elasticsearch::config(
  $java_home = $elasticsearch::params::java_home) inherits elasticsearch::params {

  #set JAVA_HOME in bashrc to avoid chicken/egg problem
  file_line { 'JAVA_HOME':
    line => $java_home,
    path => '/etc/environment',
    require => Class['elasticsearch::install']
  }  

  file {"/etc/init.d/elasticsearch":
    ensure => present,
    mode => 750,
    content => template("elasticsearch/init.d/elasticsearch.erb")
  }
}
