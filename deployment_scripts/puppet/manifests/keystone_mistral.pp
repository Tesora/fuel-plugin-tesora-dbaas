#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral keystone_mistral.pp')

class tesora_mistral::keystone_mistral {

  Class['::osnailyfacter::wait_for_keystone_backends'] -> Class['::mistral::keystone::auth']

  class { '::osnailyfacter::wait_for_keystone_backends':}
  class { '::mistral::keystone::auth':
    password            => $tesora_mistral::password,
    auth_name           => $tesora_mistral::auth_name,
    configure_endpoint  => $tesora_mistral::configure_endpoint,
    configure_user      => $tesora_mistral::configure_user,
    configure_user_role => $tesora_mistral::configure_user_role,
    service_name        => $tesora_mistral::service_name,
    service_type        => $tesora_mistral::service_type,
    public_url          => $tesora_mistral::public_url,
    internal_url        => $tesora_mistral::internal_url,
    admin_url           => $tesora_mistral::admin_url,
    region              => $tesora_mistral::region,
    tenant              => $tesora_mistral::tenant,
  }
}

class {'tesora_mistral::keystone_mistral':}
