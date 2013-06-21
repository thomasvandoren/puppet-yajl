# == Class: yajl
#
# Install and configure Yet Another JSON Library (yajl).
#
# === Parameters
#
# [*version*]
#   Version of yajl to install.
#   Default: 2.0.1
#
# [*yajl_src_dir*]
#   Location to unpack source code.
#   Default: /opt/yajl-src
#
# [*yajl_bin_dir*]
#   Location to use as "prefix" argument when building and installing yajl.
#   Default: /usr/local
#
# === Authors
#
# Thomas Van Doren
#
# === Copyright
#
# Copyright 2013 Thomas Van Doren, unless otherwise noted
#
class yajl (
  $version      = '2.0.1'
  $yajl_src_dir = '/opt/yajl-src',
  $yajl_bin_dir = '/usr/local',
  ) {
  include wget

  $yajl_pkg_name = "${version}.tar.gz}"
  $yajl_pkg = "${yajl_src_dir}/${yajl_pkg_name}"
  File {
    owner => 'root',
    group => 'root',
  }
  file { $yajl_src_dir:
    ensure => directory,
  }

  # TODO: Safely install cmake! (thomasvandoren, 2013-06-20)
  package { 'cmake':
    ensure => present,
  }

  exec { 'get-yajl-pkg':
    command => "/usr/bin/wget --output-document ${yajl_pkg} https://github.com/lloyd/yajl/archive/${yajl_pkg_name}",
    creates => $yajl_pkg,
    require => File[$yajl_src_dir],
  }

  exec { 'unpack-yajl':
    command => "tar --strip-components 1 --extract --gzip --file ${yajl_pkg} --directory ${yajl_src_dir}",
    cwd     => $yajl_src_dir,
    path    => '/bin:/usr/bin',
    creates => "${yajl_src_dir}/configure",
    require => Exec['get-yajl-pkg'],
  }

  exec { 'configure-yajl':
    command => "ruby configure --prefix ${yajl_bin_dir}",
    cwd     => $yajl_src_dir,
    creates => "${yajl_src_dir}/Makefile",
    require => [ Exec['unpack-yajl'], Package['cmake'] ],
  }

  exec { 'install-yajl':
    command => "make && make install PREFIX=${yajl_bin_dir}",
    cwd     => $yajl_src_dir,
    creates => "${yajl_bin_dir}/lib/libyajl.so",
    require => Exec['configure-yajl'],
  }
}
