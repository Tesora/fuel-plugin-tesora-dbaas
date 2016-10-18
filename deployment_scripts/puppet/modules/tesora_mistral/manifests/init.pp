#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

# There's really no "sensible defaults" for these parameters.
class tesora_mistral (
    $primary_controller = undef,
    $keystone_admin_url = undef,
    $keystone_public_url = undef,
    $keystone_admin_user = undef,
    $keystone_admin_pass = undef,
    $keystone_admin_tenant = undef,
    $mistral_admin_url = undef,
    $mistral_public_url = undef,
    $mistral_bind_host = undef,
    $mistral_region = undef,
    $mistral_mysql_user = undef,
    $mistral_mysql_pass = undef,
    $mistral_admin_user = undef,
    $mistral_admin_pass = undef,
    $mistral_admin_tenant = undef,
    $rabbit_hosts = undef,
    $rabbit_user = undef,
    $rabbit_pass = undef,
    $controller_host = undef,
    $mysql_host_port = undef,
    $guest_download_user = undef,
    $guest_download_pass = undef,
) {
    notice ('tesora_mistral::init.pp')

    class { 'tesora_mistral::configure_mistral': }
}
