#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral configure_mistral.pp')

$ip_management    = hiera('management_vip')
$ip_public        = hiera('public_vip')
$ssl_hash         = hiera_hash('use_ssl', {})
$network_metadata = hiera_hash('network_metadata', {})
$public_ssl_hash   = hiera_hash('public_ssl', {})


# ---------- NOVA -----------------------------------------------
$nova_hash         = hiera_hash('nova', { })
$nova_admin_tenant = pick($nova_hash['tenant'], 'services')

# ---------- KEYSTONE -----------------------------------------------
$access_hash   = hiera_hash('access',{})

$keystone_admin_user   = $access_hash['user']
$keystone_admin_pass   = $access_hash['password']
$keystone_admin_tenant = $access_hash['tenant']

$keystone_public_protocol = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'protocol', 'http')
$keystone_public_address  = get_ssl_property($ssl_hash, $public_ssl_hash, 'keystone', 'public', 'hostname', [$ip_public])
$keystone_public_url      = "${keystone_public_protocol}://${keystone_public_address}:5000/v2.0"

$keystone_internal_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
$keystone_internal_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [$ip_management])
$keystone_internal_url      = "${keystone_internal_protocol}://${keystone_internal_address}:5000/v2.0"

$keystone_admin_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$keystone_admin_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', [$ip_management])
$keystone_admin_url      = "${keystone_admin_protocol}://${keystone_admin_address}:35357/v2.0"

# ---------- RABBIT -----------------------------------------------
$tesora_hash        = hiera_hash('fuel-plugin-tesora-dbaas')
$amqp_port          = pick($tesora_hash['rabbit_port'], '55671')
# controller vip/haproxy is handling HA for rabbit
$mistral_rabbit_hosts = "${ip_management}:${amqp_port}"

# ---------- MYSQL -----------------------------------------------
$ip_database    = hiera('database_vip', $ip_management)
$mysql_hash     = hiera_hash('mysql', {})

$mysql_host_port  = "${ip_database}:3306"

# ---------- MISTRAL -----------------------------------------------
$mistral_public_url = "http://${ip_public}:8989"
$mistral_admin_url  = "http://${ip_management}:8989"

# ---------- PLUGIN UI/metadata ----------------------------------
$mistral_mysql_user    = pick($tesora_hash['mistral_mysql_user'], 'mistral')
$mistral_mysql_pass    = $tesora_hash['mistral_mysql_password']
$mistral_admin_user    = pick($tesora_hash['admin_user'], 'mistral')
$mistral_admin_pass    = $tesora_hash['admin_password']
$mistral_rabbit_user   = pick($tesora_hash['rabbit_user'], 'mistral')
$mistral_rabbit_pass   = $tesora_hash['rabbit_password']
$guest_download_user = $tesora_hash['tesora_guest_download_username']
$guest_download_pass = $tesora_hash['tesora_guest_download_password']

$network_scheme      = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)
$mistral_bind_host     = get_network_role_property('mistral/api', 'ipaddr')
$mistral_admin_tenant = pick($tesora_hash['tenant'], $nova_admin_tenant)
$mistral_region     = hiera('region', 'RegionOne')

$primary_controller = hiera('primary_controller')

class { 'tesora_mistral':
  primary_controller    => $primary_controller,
  keystone_admin_url    => $keystone_admin_url,
  keystone_public_url   => $keystone_public_url,
  keystone_admin_user   => $keystone_admin_user,
  keystone_admin_pass   => $keystone_admin_pass,
  keystone_admin_tenant => $keystone_admin_tenant,

  mistral_public_url      => $mistral_public_url,
  mistral_admin_url       => $mistral_admin_url,

  mistral_bind_host       => $mistral_bind_host,

  mistral_region          => $mistral_region,
  mistral_mysql_user      => $mistral_mysql_user,
  mistral_mysql_pass      => $mistral_mysql_pass,

  mistral_admin_user      => $mistral_admin_user,
  mistral_admin_pass      => $mistral_admin_pass,
  mistral_admin_tenant    => $mistral_admin_tenant,

  rabbit_hosts          => $mistral_rabbit_hosts,
  rabbit_user           => $mistral_rabbit_user,
  rabbit_pass           => $mistral_rabbit_pass,

  controller_host       => $keystone_admin_address,

  mysql_host_port       => $mysql_host_port,

  guest_download_user   => $guest_download_user,
  guest_download_pass   => $guest_download_pass,
}
