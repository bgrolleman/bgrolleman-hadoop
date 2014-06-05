# == Class: hadoop::install
#
# Install hadoop, should not be used outside module
#
# * Download if needed
# * Unpack
# * Setup user
#
class hadoop::install {
  # Defaults
  Exec {
    path  => ['/bin','/usr/bin', '/sbin','/usr/sbin']
  }
  File {
    owner   => $hadoop::user,
    group   => $hadoop::group,
    require => [User[$hadoop::user],Group[$hadoop::group]]
  }

  # Fetch Hadoop
  wget::fetch { 'FetchHadoop':
    source      => $hadoop::source,
    destination => '/opt/hadoop.tar.gz',
    cache_dir   => '/var/cache/wget',
    notify      => Exec['UnpackHadoop']
  }

  user { $hadoop::user:
    ensure => present,
    home   => $hadoop::installdir;
  }
  group { $hadoop::group:
    ensure => present;
  }

  file { $hadoop::installdir:
    ensure  => directory,
    recurse => true,
    mode    => '0755',
  }
  file { "${hadoop::installdir}/.ssh":
    ensure => directory,
    mode   => '0700'
  }

  # Unpack Hadoop
  exec { 'UnpackHadoop':
    cwd         => $hadoop::installdir,
    refreshonly => true,
    command     => 'tar zxf /opt/hadoop.tar.gz --strip-components 1',
    require     => [User[$hadoop::user],Group[$hadoop::group],File[$hadoop::installdir]];
  }

  # SSH Keys
  if ( $hadoop::private_key == undef ) {
    # If all we need is a single node than we can just generate the ssh key
    exec { 'ssh-keygen -t dsa -q':
      user    => $hadoop::user,
      creates => "${hadoop::installdir}/.ssh/id_dsa",
      notify  => Exec['AddKeyToAuthorizedKeyFile'],
      require => [User[$hadoop::user],File["${hadoop::installdir}/.ssh"]];
    }
    exec { 'AddKeyToAuthorizedKeyFile':
      command     => "cat ${hadoop::installdir}/.ssh/id_dsa.pub >> ${hadoop::installdir}/.ssh/auhtorized_keys",
      user        => $hadoop::user,
      refreshonly => true
    }
  } else {
    # With multiple nodes we want a central key to be deployed to all hosts
    if ( $hadoop::public_key == undef ) {
      fail('Please provide a public ssh key matching the private ssh key')
    }
    file { "${hadoop::installdir}/.ssh/id_dsa":
      content => $hadoop::private_key,
      mode    => '0600'
    }
    authorized_key_file { "${hadoop::user}@cluster":
      key   => $hadoop::private_key,
      owner => $hadoop::user,
      group => $hadoop::group,
      mode  => '0600'
    }

  }

}
