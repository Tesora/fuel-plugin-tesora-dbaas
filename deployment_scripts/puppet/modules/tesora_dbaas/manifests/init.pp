#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

# There's really no "sensible defaults" for these parameters.
class tesora_dbaas (
    $primary_controller = undef,
    $keystone_admin_url = undef,
    $keystone_public_url = undef,
    $keystone_admin_user = undef,
    $keystone_admin_pass = undef,
    $keystone_admin_tenant = undef,
    $trove_admin_url = undef,
    $trove_public_url = undef,
    $trove_bind_host = undef,
    $trove_region = undef,
    $trove_mysql_user = undef,
    $trove_mysql_pass = undef,
    $trove_admin_user = undef,
    $trove_admin_pass = undef,
    $trove_admin_tenant = undef,
    $cinder_url = undef,
    $swift_admin_url = undef,
    $swift_public_url = undef,
    $nova_url = undef,
    $nova_user = undef,
    $nova_pass = undef,
    $nova_tenant = undef,
    $rabbit_hosts = undef,
    $rabbit_user = undef,
    $rabbit_pass = undef,
    $guest_rabbit_hosts = undef,
    $controller_host = undef,
    $mysql_host_port = undef,
    $mysql_admin_user = undef,
    $mysql_admin_pass = undef,
    $guest_download_user = undef,
    $guest_download_pass = undef,
) {
    notice ('tesora_dbaas::init.pp')

    Class['tesora_dbaas::configure'] -> Class['tesora_dbaas::config_client']

    class { 'tesora_dbaas::configure': }

    class { 'tesora_dbaas::config_client':
      os_auth_url         => $keystone_public_url,
      os_user             => $keystone_admin_user,
      os_pass             => $keystone_admin_pass,
      os_tenant_name      => $keystone_admin_tenant,
      guest_download_user => $guest_download_user,
      guest_download_pass => $guest_download_pass,
      dbaas_release       => 'enterprise',
      dbaas_version       => '1.9',
      dbaas_repo          => 'main',
    }
}
