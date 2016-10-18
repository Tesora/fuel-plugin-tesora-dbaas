#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas configure.pp')

$ip_management    = hiera('management_vip')
$ip_public        = hiera('public_vip')
$ssl_hash         = hiera_hash('use_ssl', {})
$network_metadata = hiera_hash('network_metadata', {})
$public_ssl_hash   = hiera_hash('public_ssl', {})

# ---------- NOVA -----------------------------------------------
$nova_endpoint    = hiera('nova_endpoint', $ip_management)
$nova_hash        = hiera_hash('nova', { })
$nova_admin_tenant = pick($nova_hash['tenant'], 'services')

# ---------- KEYSTONE -----------------------------------------------
$access_hash   = hiera_hash('access',{})

$keystone_admin_user   = $access_hash['user']
$keystone_admin_pass   = $access_hash['password']
$keystone_admin_tenant = $access_hash['tenant']

$keystone_url_version = "v3"
$keystone_public_protocol = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'protocol', 'http')
$keystone_public_address  = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'hostname', [$ip_public])
$keystone_public_url         = "${keystone_public_protocol}://${keystone_public_address}:5000/${keystone_url_version}"
$keystone_public_unversioned = "${keystone_public_protocol}://${keystone_public_address}:5000"

$keystone_internal_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
$keystone_internal_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [$ip_management])
$keystone_internal_url      = "${keystone_internal_protocol}://${keystone_internal_address}:5000/${keystone_url_version}"

$keystone_admin_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$keystone_admin_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [$ip_management])
$keystone_admin_url      = "${keystone_admin_protocol}://${keystone_admin_address}:35357/${keystone_url_version}"

# ---------- RABBIT -----------------------------------------------
$tesora_hash        = hiera_hash('fuel-plugin-tesora-dbaas')
$amqp_port          = pick($tesora_hash['rabbit_port'], '55671')
# controller vip/haproxy is handling HA for rabbit
$trove_rabbit_hosts = "${ip_management}:${amqp_port}"
$trove_guest_rabbit_hosts = "${ip_public}:${amqp_port}"

# ---------- MYSQL -----------------------------------------------
$ip_database    = hiera('database_vip', $ip_management)
$mysql_hash     = hiera_hash('mysql', {})

$mysql_host_port  = "${ip_database}:3306"
$mysql_admin_user = pick($mysql_hash['root_user'], 'root')
$mysql_admin_pass = $mysql_hash['root_password']

# ---------- TROVE -----------------------------------------------
$trove_public_url = "http://${ip_public}:8779"
$trove_admin_url  = "http://${ip_management}:8779"

# ---------- PLUGIN UI/metadata ----------------------------------
$trove_mysql_user    = pick($tesora_hash['mysql_user'], 'trove')
$trove_mysql_pass    = $tesora_hash['mysql_password']
$trove_admin_user    = pick($tesora_hash['admin_user'], 'trove')
$trove_admin_pass    = $tesora_hash['admin_password']
$trove_rabbit_user   = pick($tesora_hash['rabbit_user'], 'trove')
$trove_rabbit_pass   = $tesora_hash['rabbit_password']
$guest_download_user = $tesora_hash['tesora_guest_download_username']
$guest_download_pass = $tesora_hash['tesora_guest_download_password']

$network_scheme      = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$trove_bind_host     = get_network_role_property('trove/api', 'ipaddr')

$trove_admin_tenant = pick($tesora_hash['tenant'], $nova_admin_tenant)

$trove_region     = hiera('region', 'RegionOne')

$primary_controller = hiera('primary_controller')

class { 'tesora_dbaas':
  primary_controller    => $primary_controller,
  keystone_admin_url    => $keystone_admin_url,
  keystone_public_url   => $keystone_public_url,
  keystone_admin_user   => $keystone_admin_user,
  keystone_admin_pass   => $keystone_admin_pass,
  keystone_admin_tenant => $keystone_admin_tenant,

  trove_public_url      => $trove_public_url,
  trove_admin_url       => $trove_admin_url,

  trove_bind_host       => $trove_bind_host,

  trove_region          => $trove_region,
  trove_mysql_user      => $trove_mysql_user,
  trove_mysql_pass      => $trove_mysql_pass,

  trove_admin_user      => $trove_admin_user,
  trove_admin_pass      => $trove_admin_pass,
  trove_admin_tenant    => $trove_admin_tenant,

  rabbit_hosts          => $trove_rabbit_hosts,
  rabbit_user           => $trove_rabbit_user,
  rabbit_pass           => $trove_rabbit_pass,

  guest_rabbit_hosts    => $trove_guest_rabbit_hosts,
  controller_host       => $keystone_admin_address,

  mysql_host_port       => $mysql_host_port,
  mysql_admin_user      => $mysql_admin_user,
  mysql_admin_pass      => $mysql_admin_pass,

  guest_download_user   => $guest_download_user,
  guest_download_pass   => $guest_download_pass,
}
