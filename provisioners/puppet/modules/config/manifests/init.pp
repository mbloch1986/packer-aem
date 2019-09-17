# == Class: config
#
# Configuration for AEM AMIs
#
# === Parameters
#
#
# === Authors
#
# James Sinclair <james.sinclair@shinesolutions.com>
#
# === Copyright
#
# Copyright © 2017	Shine Solutions Group, unless otherwise noted.
#
class config (
  $package_manager_packages = {},
  $os_group                 = 'shinesolutions',
) {

  Exec {
    cwd     => $tmp_dir,
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    timeout => 0,
  }


  # Ensure we have a working FQDN <=> IP mapping.
  host { $facts['fqdn']:
    ensure       => present,
    ip           => $facts['ipaddress'],
    host_aliases => $facts['hostname'],
  }

  # Create os group
  group { $os_group:
    ensure => 'present'
  }

  $package_manager_packages.each | Integer $index, $package_details| {

    $package_name = $package_details['name']

    $package_version = pick(
      $package_details['version'],
      'latest'
    )

    $package_provider = pick(
      $package_details['provider'],
      false
    )

    if $package_provider {
      package { $package_name:
        ensure   => $package_version,
        provider => $package_provider,
      }
    } else {
      package { $package_name:
        ensure   => $package_version,
      }
    }
  }
  # Copy rsyslog configuration file to configure
  file { '/etc/rsyslog.d/shinesolutions.config':
    ensure  => present,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => epp(
      'config/rsyslog/shinesolutions.conf.epp',
      {
        'rsyslog_group' => $os_group
      }
    ),
    require => Group[$os_group],
    notify => Exec['reload rsyslog with custom shinesolution config'],
  }

  exec { "Update group owner for /var/log to ${os_group}":
    command => "chgrp -R ${os_group} /var/log",
    require => [
                  Group[$os_group],
                  File['/etc/rsyslog.d/shinesolutions.config']
               ]
  }

  exec { 'Update group permissions to rx for dir /var/log':
    command => "chmod g+rx /var/log",
    require => [
                  Group[$os_group],
                  File['/etc/rsyslog.d/shinesolutions.config']
               ]
  }

  exec { 'Update group permissions to r for everything in /var/log':
    command => "chmod -R g+r /var/log",
    require => [
                  Exec['Update group permissions to rx for dir /var/log']
               ]
  }

  exec { 'reload rsyslog with custom shinesolution config':
    command     => '/bin/pkill -HUP rsyslogd',
    refreshonly => true,
  }
}
