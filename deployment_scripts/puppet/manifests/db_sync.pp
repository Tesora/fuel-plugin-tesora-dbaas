#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas db_sync.pp')

$ip_database    = hiera('database_vip', $ip_management)
$mysql_hash     = hiera_hash('mysql', {})
$mysql_host_port  = "${ip_database}:3306"

$tesora_hash         = hiera_hash('fuel-plugin-tesora-dbaas')
$trove_mysql_user    = pick($tesora_hash['metadata']['mysql_user'], 'trove')
$trove_mysql_pass    = $tesora_hash['metadata']['mysql_password']
$trove_mysql_databasename = "trove"

class { 'tesora_dbaas::db_sync':
    trove_mysql_user          => $trove_mysql_user,
    trove_mysql_pass          => $trove_mysql_pass,
    trove_mysql_host_port     => $mysql_host_port,
    trove_mysql_databasename  => $trove_mysql_databasename,
}
