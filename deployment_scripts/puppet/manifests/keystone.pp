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
$api_bind_port      = '8779'
$trove_admin_user   = pick($tesora_dbaas_hash['admin_user'], 'trove')
$trove_admin_pass   = $tesora_dbaas_hash['admin_password']
$trove_admin_tenant = 'service'

$region             = pick(hiera('region', 'RegionOne'))
$service_name       = 'trove'
$public_address     = $public_ssl_hash['services'] ? {
  true    => $public_ssl_hash['hostname'],
  default => $public_vip,
}
$public_protocol = $public_ssl_hash['services'] ? {
  true    => 'https',
  default => 'http',
}
$public_url         = "${public_protocol}://${public_address}:${api_bind_port}/v1.0/%(tenant_id)s"
$admin_url          = "http://${admin_address}:${api_bind_port}/v1.0/%(tenant_id)s"

Class['::osnailyfacter::wait_for_keystone_backends'] -> Keystone_service['trove']

class {'::osnailyfacter::wait_for_keystone_backends':}

keystone_user { $trove_admin_user:
  ensure   => present,
  enabled  => 'True',
  password => $trove_admin_pass,
}

keystone_user_role { "${trove_admin_user}@${trove_admin_tenant}":
  ensure => present,
  roles  => 'admin',
}

keystone_service {'trove':
  ensure      => present,
  type        => 'database',
  description => 'Tesora DBaaS Platform',
}

keystone_endpoint {"${region}/trove":
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
    name     => 'tesora_dbaas',
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

