#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas install_horizon.pp')

file { '/tmp/tesora-horizon':
  source  => 'puppet:///modules/tesora_dbaas/tesora-horizon',
  recurse => true,
}

exec { 'install-tesora-dbaas-horizon':
  command => '/usr/bin/python setup.py install',
  cwd     => '/tmp/tesora-horizon',
  require => File['/tmp/tesora-horizon'],
}

exec { 'mkdir /usr/share/openstack-dashboard/openstack_dashboard/local':
  command => '/bin/mkdir -p /usr/share/openstack-dashboard/openstack_dashboard/local'
}

# Copy the enable scripts into local/enabled
file { 'copy-enable-files':
  path    => '/usr/share/openstack-dashboard/openstack_dashboard/local/enabled',
  source  => 'puppet:///modules/tesora_dbaas/tesora-horizon-config',
  recurse => true,
  require => [ Exec['install-tesora-dbaas-horizon'], Exec['mkdir /usr/share/openstack-dashboard/openstack_dashboard/local'] ],
}

# Append the tesora overrides line to local_settings
file_line { 'add-overrides':
  require => File['copy-enable-files'],
  path    => '/etc/openstack-dashboard/local_settings.py',
  line    => 'HORIZON_CONFIG['customization_module'] = "tesora_horizon.overrides"',
}

# The reality is that these have already been installed by horizon package install:
package { 'python-troveclient':       ensure => 'installed' }
package { 'tesora-dbaas-client':      ensure => 'installed' }
