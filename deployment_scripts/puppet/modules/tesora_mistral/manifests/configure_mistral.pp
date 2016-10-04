#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::configure {
  # Replace the mistral-setup.sh that comes in the package.
  file { '/opt/tesora/dbaas/bin/mistral-setup.sh':
    ensure => absent,
  }

  file { '/opt/tesora/dbaas/bin/fuel_dbaas_mistral-setup.sh':
    ensure => present,
    source => 'puppet:///modules/tesora_mistral/mistral-setup.sh',
  }

  file { '/tmp/mistral_setup.cfg':
    ensure  => file,
    content => template('tesora_mistral/mistral_setup.cfg.erb')
  }

  exec { 'install':
    command   => "/opt/tesora/dbaas/bin/fuel_dbaas_mistral-setup.sh /tmp/mistral_setup.cfg ${::primary_controller}",
    logoutput => true,
    require   => [ File['/opt/tesora/dbaas/bin/fuel_dbaas_mistral-setup.sh'], File['/tmp/mistral_setup.cfg'] ],
    onlyif    => '/usr/bin/test True',
    notify    => [ Service['mistral-api'], Service['mistral-engine'], Service['mistral-executor'] ]
  }

  require 'mysql::bindings'
  require 'mysql::bindings::python'

  # TODO: we want to be restarting the services on conf file changes
  Service { ensure => running, enable => true, require => Exec['install'] }

  service { 'mistral-api': }
  service { 'mistral-engine': }
  service { 'mistral-executor': }

  $firewall_rule = '239 tesora_mistral'

  firewall { $firewall_rule :
    dport  => 8779,
    proto  => 'tcp',
    action => 'accept',
  }
}
