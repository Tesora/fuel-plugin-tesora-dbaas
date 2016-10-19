#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

# This creates two files of importance
# we create the /root/openrc to look like it does on the controller.
# We then create our tesora openrc file that contains those contents, plus
# additional Tesora DBaaS related environment variables.

class tesora_dbaas::config_client (
    $os_auth_url = undef,
    $os_user = undef,
    $os_pass = undef,
    $os_tenant_name = undef,
    $os_region = undef,
    $guest_download_user = undef,
    $guest_download_pass = undef,
    $dbaas_release = undef,
    $dbaas_version = undef,
    $dbaas_repo = undef,
) {

  osnailyfacter::credentials_file { '/root/openrc':
    admin_user          => $os_user,
    admin_password      => $os_pass,
    admin_tenant        => $os_tenant_name,
    region_name         => $os_region,
    auth_url            => $os_auth_url,
  }

  file { '/tmp/tesoradbaasrc.sh':
    ensure  => file,
    content => template('tesora_dbaas/tesoradbaasrc.sh.erb')
  }

  exec { 'openrc-concat':
    command => '/bin/cat /root/openrc /tmp/tesoradbaasrc.sh > /opt/tesora/dbaas/bin/openrc.sh',
    require => [ File['/root/openrc'], File['/tmp/tesoradbaasrc.sh']],
  }

}
