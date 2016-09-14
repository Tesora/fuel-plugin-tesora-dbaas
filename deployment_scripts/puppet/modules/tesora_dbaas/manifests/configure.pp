#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::configure {
  # Replace the setup.sh that comes in the package.
  file { '/opt/tesora/dbaas/bin/setup.sh':
    ensure => absent,
  }

  file { '/opt/tesora/dbaas/bin/fuel_dbaas_setup.sh':
    ensure => present,
    source => 'puppet:///modules/tesora_dbaas/setup.sh',
  }

  file { '/tmp/setup.cfg':
    ensure  => file,
    content => template('tesora_dbaas/setup.cfg.erb')
  }

  exec { 'install':
    command   => "/opt/tesora/dbaas/bin/fuel_dbaas_setup.sh /tmp/setup.cfg ${::primary_controller}",
    logoutput => true,
    require   => [ File['/opt/tesora/dbaas/bin/fuel_dbaas_setup.sh'], File['/tmp/setup.cfg'] ],
    onlyif    => '/usr/bin/test True',
    notify    => [ Service['trove-api'], Service['trove-taskmanager'], Service['trove-conductor'] ]
  }

  require 'mysql::bindings'
  require 'mysql::bindings::python'

  # TODO: we want to be restarting the services on conf file changes
  Service { ensure => running, enable => true, require => Exec['install'] }

  service { 'trove-api': }
  service { 'trove-taskmanager': }
  service { 'trove-conductor': }

  $firewall_rule = '239 tesora_dbaas'

  firewall { $firewall_rule :
    dport  => 8779,
    proto  => 'tcp',
    action => 'accept',
  }

}
