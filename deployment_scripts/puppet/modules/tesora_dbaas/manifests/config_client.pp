#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::config_client (
    $os_auth_url = undef,
    $os_mistral_url = undef,
    $os_user = undef,
    $os_pass = undef,
    $os_tenant_name = undef,
    $guest_download_user = undef,
    $guest_download_pass = undef,
    $dbaas_release = undef,
    $dbaas_version = undef,
    $dbaas_repo = undef,
) {
  file { '/opt/tesora/dbaas/bin/openrc.sh':
    ensure  => file,
    content => template('tesora_dbaas/openrc.sh.erb')
  }
}

