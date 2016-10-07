#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral db_sync_mistral.pp')

$ip_database    = hiera('database_vip', $ip_management)
$mysql_hash     = hiera_hash('mysql', {})
$mysql_host_port  = "${ip_database}:3306"

$tesora_hash         = hiera_hash('fuel-plugin-tesora-dbaas')
$mistral_mysql_user  = pick($tesora_hash['mysql_user'], 'mistral')
$mistral_mysql_pass  = $tesora_hash['mysql_password']
$trove_mysql_databasename = 'mistral'

class { 'tesora_mistral::db_sync':
    mistral_mysql_user         => $mistral_mysql_user,
    mistral_mysql_pass         => $mistral_mysql_pass,
    mistral_mysql_host_port    => $mysql_host_port,
    mistral_mysql_databasename => $mistral_mysql_databasename,
}
