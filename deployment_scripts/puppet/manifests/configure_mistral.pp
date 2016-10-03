#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral configure_mistral.pp')

class tesora_mistral::configure_mistral {

  $roles = hiera(roles)

  Package <| title == 'mistral-common' |> {
    name => 'mistral-common',
  }
  class { '::mistral':
    keystone_password                  => $tesora_mistral::password,
    keystone_user                      => $tesora_mistral::auth_name,
    keystone_tenant                    => $tesora_mistral::tenant,
    auth_uri                           => $tesora_mistral::auth_uri,
    identity_uri                       => $tesora_mistral::identity_uri,
    database_connection                => $tesora_mistral::db_connection,
    rpc_backend                        => $tesora_mistral::rpc_backend,
    rabbit_hosts                       => $tesora_mistral::rabbit_hosts,
    rabbit_userid                      => $tesora_mistral::rabbit_hash['user'],
    rabbit_password                    => $tesora_mistral::rabbit_hash['password'],
    control_exchange                   => $tesora_mistral::control_exchange,
    rabbit_ha_queues                   => $tesora_mistral::rabbit_ha_queues,
    use_syslog                         => $tesora_mistral::use_syslog,
    use_stderr                         => $tesora_mistral::use_stderr,
    log_facility                       => $tesora_mistral::log_facility,
    verbose                            => $tesora_mistral::verbose,
    debug                              => $tesora_mistral::debug,
  }

  mistral_config {
    'keystone_authtoken/auth_version': value => $tesora_mistral::auth_version;
  }
}

class {'tesora_mistral::configure_mistral':}
