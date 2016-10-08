#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral executor_mistral.pp')

class mistral::executor (
  $package_ensure      = present,
  $manage_service      = true,
  $enabled             = true,
  $host                = $::os_service_default,
  $topic               = $::os_service_default,
  $version             = $::os_service_default,
  $evaluation_interval = $::os_service_default,
  $older_than          = $::os_service_default,
) {

  include ::mistral::params

  package { 'mistral-executor':
    ensure => $package_ensure,
    name   => $::mistral::params::executor_package_name,
    tag    => ['openstack', 'mistral-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'mistral-executor':
    ensure     => $service_ensure,
    name       => $::mistral::params::executor_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => 'mistral-service',
  }

  mistral_config {
    'executor/host' :                                   value => $host;
    'executor/topic' :                                  value => $topic;
    'executor/version' :                                value => $version;
    'execution_expiration_policy/evaluation_interval' : value => $evaluation_interval;
    'execution_expiration_policy/older_than' :          value => $older_than;
  }

}
