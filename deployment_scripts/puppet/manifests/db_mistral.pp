#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral db_mistral.pp')

$node_name           = hiera('node_name')

$tesora_dbaas_hash   = hiera_hash('fuel-plugin-tesora-dbaas')
$mistral_enabled     = pick($tesora_dbaas_hash['metadata']['enabled'], true)
$mysql_hash          = hiera_hash('mysql', {})

$database_vip        = hiera('database_vip', undef)

$mysql_root_user     = pick($mysql_hash['root_user'], 'root')
$mysql_db_create     = pick($mysql_hash['db_create'], true)
$mysql_root_password = $mysql_hash['root_password']

$db_user             = pick($tesora_dbaas_hash['mistral_mysql_user'], 'mistral')
$db_name             = pick($tesora_dbaas_hash['mistral_mysql_db_name'], 'mistral')
$db_password         = pick($tesora_dbaas_hash['mistral_mysql_password'], $mysql_root_password)

$db_host             = pick($tesora_dbaas_hash['mysql_db_host'], $database_vip)
$db_create           = pick($tesora_dbaas_hash['mysql_db_create'], $mysql_db_create)
$db_root_user        = pick($tesora_dbaas_hash['mysql_root_user'], $mysql_root_user)
$db_root_password    = pick($tesora_dbaas_hash['mysql_root_password'], $mysql_root_password)

# TODO: removed $node_name
$allowed_hosts       = [ 'localhost', '127.0.0.1', '%' ]

validate_string($db_root_password)

if $mistral_enabled and $db_create {

  class { 'openstack::galera::client':
    custom_setup_class => hiera('mysql_custom_setup_class', 'galera'),
  }

  class { 'osnailyfacter::mysql_access':
    db_host     => $db_host,
    db_user     => $db_root_user,
    db_password => $db_root_password,
  }

  validate_string($db_password)

  ::openstacklib::db::mysql { 'mistral':
    user          => $db_user,
    password_hash => mysql_password($db_password),
    dbname        => $db_name,
    host          => '127.0.0.1',
    charset       => 'utf8',
    collate       => 'utf8_general_ci',
    allowed_hosts => $allowed_hosts,
  }

  Class['openstack::galera::client'] ->
    Class['osnailyfacter::mysql_access'] ->
      ::Openstacklib::Db::Mysql['mistral']
}

class mysql::config{}
include mysql::config
class mysql::server{}
include mysql::server
