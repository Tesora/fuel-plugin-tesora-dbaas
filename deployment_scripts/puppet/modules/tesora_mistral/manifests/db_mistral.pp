#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::db_mistral {

  if $tesora_mistral::db_create {

    class { '::openstack::galera::client':
      custom_setup_class => hiera('mysql_custom_setup_class', 'galera'),
    }

    class { '::mistral::db::mysql':
      user          => $tesora_mistral::db_user,
      password      => $tesora_mistral::db_password,
      dbname        => $tesora_mistral::db_name,
      allowed_hosts => $tesora_mistral::allowed_hosts,
    }

    class { '::osnailyfacter::mysql_access':
      db_host     => $tesora_mistral::db_host,
      db_user     => $tesora_mistral::db_root_user,
      db_password => $tesora_mistral::db_root_password,
    }

    Class['::openstack::galera::client'] ->
      Class['::osnailyfacter::mysql_access'] ->
        Class['::mistral::db::mysql']

  }

}
