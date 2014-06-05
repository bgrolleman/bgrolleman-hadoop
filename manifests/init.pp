# == Class: hadoop
#
# Module to install hadoop
#
# === Parameters
#
# Document parameters here.
#
# [*source*]
#   Provide link to hadoop source, best is to use a local mirror
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { hadoop:
#    source  => 'http://apache.mirror.1000mbps.com/hadoop/core/current/hadoop-2.4.0.tar.gz'
#  }
#
# === Authors
#
# Bas Grolleman <bgrolleman@emendo-it.nl>
#
# === Copyright
#
# Copyright 2014 Bas Grolleman, unless otherwise noted.
#
class hadoop (
  $source      = undef,
  $private_key = undef,
  $public_key  = undef,
  $installdir  = '/opt/hadoop',
  $user        = 'hadoop',
  $group       = 'hadoop'
) {
  # Check variables
  if ( $source == undef ) {
    fail('Please provide a source value in hadoop module')
  }

  # Make sure we order things right
  Class['hadoop::install'] -> Class['hadoop::config'] ~> Class['hadoop::service']

  include hadoop::install
  include hadoop::config
  include hadoop::service

}
