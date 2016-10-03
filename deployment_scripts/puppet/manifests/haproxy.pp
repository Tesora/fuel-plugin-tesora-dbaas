#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#


notice('tesora_dbaas haproxy.pp')

$network_metadata = hiera_hash('network_metadata', {})
$ip_management    = hiera('management_vip')
$ip_public        = hiera('public_vip')
$ssl_hash         = hiera_hash('use_ssl', {})
$public_ssl_hash  = hiera('public_ssl')
$public_ssl_path  = get_ssl_property($ssl_hash, $public_ssl_hash, 'tesora-dbaas', 'public', 'path', [''])

$trove_nodes = get_nodes_hash_by_roles($network_metadata, ['tesora-dbaas'])
$trove_address_map = get_node_to_ipaddr_map_by_network_role($trove_nodes, 'trove/api')

Openstack::Ha::Haproxy_service {
  internal_virtual_ip => $ip_management,
  ipaddresses         => values($trove_address_map),
  server_names        => keys($trove_address_map),
}

openstack::ha::haproxy_service { 'tesora-dbaas':
  order                  => '210',
  listen_port            => 8779,
  public                 => true,
  public_ssl             => $public_ssl_hash['services'],
  public_ssl_path        => $public_ssl_path,
  public_virtual_ip      => $ip_public,
  haproxy_config_options => {
      'http-request' => 'set-header X-Forwarded-Proto https if { ssl_fc }',
  },
}

openstack::ha::haproxy_service { 'trove-rabbitmq':
  order                  => '211',
  listen_port            => 55671,
  define_backups         => true,
  internal               => true,
  public                 => true,
  public_virtual_ip      => $ip_public,
  haproxy_config_options => {
    'option'         => ['tcpka'],
    'timeout client' => '48h',
    'timeout server' => '48h',
    'balance'        => 'roundrobin',
    'mode'           => 'tcp'
  },
  balancermember_options => 'check inter 5000 rise 2 fall 3',
}
