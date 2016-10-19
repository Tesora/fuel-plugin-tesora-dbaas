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
    $guest_download_user = undef,
    $guest_download_pass = undef,
    $dbaas_release = undef,
    $dbaas_version = undef,
    $dbaas_repo = undef,
) {

  osnailyfacter::credentials_file { '/root/openrc':
    admin_user          => $os_user,
    admin_password      => $os_password,
    admin_tenant        => $os_tenant_name,
    #TBDregion_name         => $region,
    auth_url            => $os_auth_url,
    #TBDmurano_repo_url     => $murano_repo_url,
    #TBDmurano_glare_plugin => $murano_glare_plugin,
  }

  concat { '/opt/tesora/dbaas/bin/openrc.sh': }
  concat::fragment { 'standard-openrc-admin-contents':
    target   => '/opt/tesora/dbaas/bin/openrc.sh',
    contents => file('/root/openrc'),
    order    => '01',
  }
  concat:fragment {'tesora-additional-vars':
    target   => '/opt/tesora/dbaas/bin/openrc.sh',
    contents => template('tesora_dbaas/tesoradbaasrc.sh.erb'
    order    => '02',
  }
}

