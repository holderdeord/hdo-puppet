class elasticsearch::params {
  $package = 'elasticsearch-0.19.9.deb'
  $dependencies = ['java7-runtime-headless', 'java7-runtime' ]
  #$java_home = '/usr/lib/jvm/java-1.7.0-openjdk-i386'
  $download_to = '/root'
}
