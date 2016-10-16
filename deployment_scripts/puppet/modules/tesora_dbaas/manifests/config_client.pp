#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::config_client (
    $os_auth_url = undef,
    $os_user = undef,
    $os_pass = undef,
    $os_tenant_name = undef,
    $os_project_domain_id = undef,
    $os_image_api_version = undef,
    $os_user_domain_id = undef,
    $os_project_name = undef,
    $os_auth_version = undef,
    $os_identity_api_version = undef,
    $os_compute_api_version = undef,
    $os_volume_api_version = undef,
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

