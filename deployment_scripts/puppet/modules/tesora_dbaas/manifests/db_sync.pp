#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::db_sync (
    $trove_mysql_user = undef,
    $trove_mysql_pass = undef,
    $trove_mysql_host_port = undef,
    $trove_mysql_databasename = undef
) {
  $trove_mysql_connectionstring = "mysql://${trove_mysql_user}:${trove_mysql_pass}@${trove_mysql_host_port}/${trove_mysql_databasename}?charset=utf8"

  require 'mysql::bindings'
  require 'mysql::bindings::python'

  file { "/etc/trove/trove_dbsync.conf":
    ensure  => file,
    content => template('tesora_dbaas/trove_dbsync.conf.erb')
  }

  exec { 'tesora_dbaas-dbsync':
    command     => 'trove-manage --debug --config-file=/etc/trove/trove_dbsync.conf db_sync',
    path        => '/usr/bin',
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => File['/etc/trove/trove_dbsync.conf'],
  }
}
