#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas keystone.pp')

$tesora_dbaas_hash  = hiera_hash('fuel-plugin-tesora-dbaas')
$public_ssl_hash    = hiera('public_ssl')
$public_vip         = hiera('public_vip')
$admin_address      = hiera('management_vip')
$mistral_api_port   = '8989'
$mistral_admin_user   = pick($tesora_dbaas_hash['mistral_admin_user'], 'mistral')
$mistral_admin_pass   = $tesora_dbaas_hash['mistral_admin_password']
$mistral_admin_tenant = 'services'

$region             = pick(hiera('region', 'RegionOne'))
$service_name       = 'mistral'
$public_address     = $public_ssl_hash['services'] ? {
  true    => $public_ssl_hash['hostname'],
  default => $public_vip,
}
$public_protocol = $public_ssl_hash['services'] ? {
  true    => 'https',
  default => 'http',
}
$public_url         = "${public_protocol}://${public_address}:${mistral_api_port}/v1.0/%(tenant_id)s"
$admin_url          = "http://${admin_address}:${mistral_api_port}/v1.0/%(tenant_id)s"

Class['::osnailyfacter::wait_for_keystone_backends'] -> Keystone_service['mistral']

class {'::osnailyfacter::wait_for_keystone_backends':}

keystone_user { $mistral_admin_user:
  ensure   => present,
  enabled  => 'True',
  password => $mistral_admin_pass,
}

keystone_user_role { "${mistral_admin_user}@${mistral_admin_tenant}":
  ensure => present,
  roles  => 'admin',
}

keystone_service {'mistral':
  ensure      => present,
  type        => 'workflow',
  description => 'Tesora DBaaS Platform',
}

keystone_endpoint {"${region}/mistral":
  ensure       => present,
  public_url   => $public_url,
  admin_url    => $admin_url,
  internal_url => $admin_url,
}

$haproxy_stats_url = "http://${management_ip}:10000/;csv"

$lb_defaults = {
  'provider' => 'haproxy',
  'url'      => $haproxy_stats_url,
}

$lb_hash = {
  tesora-dbaas => {
    name     => 'tesora_dbaas_mistral',
    provider => $public_protocol,
    url      => $admin_url
  }
}

# I do not thing we can do this.
# we have not configured haproxy at this point based on current deployment tasks configuration
#::osnailyfacter::wait_for_backend {'tesora_dbaas':
#  lb_hash     => $lb_hash,
#  lb_defaults => $lb_defaults
#}

