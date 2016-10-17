#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral haproxy_mistral.pp')

$network_metadata = hiera_hash('network_metadata', {})
$ip_management    = hiera('management_vip')
$ip_public        = hiera('public_vip')
$ssl_hash         = hiera_hash('use_ssl', {})
$public_ssl_hash  = hiera('public_ssl')
$public_ssl_path  = get_ssl_property($ssl_hash, $public_ssl_hash, 'tesora-dbaas', 'public', 'path', [''])
$mistral_port     = 8989

$dbaas_nodes = get_nodes_hash_by_roles($network_metadata, ['tesora-dbaas'])
$mistral_address_map = get_node_to_ipaddr_map_by_network_role($dbaas_nodes, 'mistral/api')

Openstack::Ha::Haproxy_service {
  internal_virtual_ip => $ip_management,
  ipaddresses         => values($mistral_address_map),
  server_names        => keys($mistral_address_map),
}

openstack::ha::haproxy_service { 'mistral':
  order                  => '210',
  listen_port            => $mistral_port,
  public                 => true,
  public_ssl             => $public_ssl_hash['services'],
  public_ssl_path        => $public_ssl_path,
  public_virtual_ip      => $ip_public,
  haproxy_config_options => {
      'http-request' => 'set-header X-Forwarded-Proto https if { ssl_fc }',
  },
}

$haproxy_stats_url = "http://${ip_management}:10000/;csv"
$mistral_protocol  = get_ssl_property($ssl_hash, {}, 'mistral', 'internal', 'protocol', 'http')
$mistral_address   = get_ssl_property($ssl_hash, {}, 'mistral', 'internal', 'hostname', [$service_endpoint, $management_vip])
$mistral_url       = "${mistral_protocol}://${mistral_address}:${$mistral_port}"

$lb_defaults = { 'provider' => 'haproxy', 'url' => $haproxy_stats_url }

$lb_hash = {
  mistral      => {
    name     => 'mistral',
    url      => $lb_url
  }
}

::osnailyfacter::wait_for_backend {'mistral':
  lb_hash     => $lb_hash,
  lb_defaults => $lb_defaults
}
