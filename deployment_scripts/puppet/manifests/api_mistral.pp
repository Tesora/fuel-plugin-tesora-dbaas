#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral api_mistral.pp')

class mistral::api (
  $allow_action_execution_deletion = $::os_service_default,
  $api_workers                     = $::os_service_default,
  $bind_host                       = $::os_service_default,
  $bind_port                       = $::os_service_default,
  $enabled                         = true,
  $manage_service                  = true,
  $package_ensure                  = present,
  $service_name                    = $::mistral::params::api_service_name,
) inherits mistral::params {

  include ::mistral::params
  include ::mistral::policy

  Mistral_config<||> ~> Service[$service_name]
  Class['mistral::policy'] ~> Service[$service_name]
  Package['mistral-api'] -> Class['mistral::policy']
  Package['mistral-api'] -> Service[$service_name]
  Package['mistral-api'] -> Service['mistral-api']

  package { 'mistral-api':
    ensure => $package_ensure,
    name   => $::mistral::params::api_package_name,
    tag    => ['openstack', 'mistral-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $service_name == $::mistral::params::api_service_name {
    service { 'mistral-api':
      ensure     => $service_ensure,
      name       => $::mistral::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'mistral-service',
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'mistral-api':
      ensure => 'stopped',
      name   => $::mistral::params::api_service_name,
      enable => false,
      tag    => 'mistral-service',
    }
    Class['mistral::db'] -> Service[$service_name]
    Service <<| title == 'httpd' |>> { tag +> 'mistral-service' }

    # we need to make sure mistral-api s stopped before trying to start apache
    Service['mistral-api'] -> Service[$service_name]
  } else {
    fail("Invalid service_name. Either mistral/openstack-mistral-api for running \
as a standalone service, or httpd for being run by a httpd server")
  }

  mistral_config {
    'api/api_workers'                      : value => $api_workers;
    'api/host'                             : value => $bind_host;
    'api/port'                             : value => $bind_port;
    'api/allow_action_execution_deletion'  : value => $allow_action_execution_deletion;
  }

}
