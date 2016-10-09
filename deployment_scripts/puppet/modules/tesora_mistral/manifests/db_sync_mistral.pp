#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::db_sync_mistral (
    $mistral_mysql_user = undef,
    $mistral_mysql_pass = undef,
    $mistral_mysql_host_port = undef,
    $mistral_mysql_databasename = undef
) {

  $mistral_mysql_connectionstring = "mysql+pymysql://${mistral_mysql_user}:${mistral_mysql_pass}@${mistral_mysql_host_port}/${mistral_mysql_databasename}?charset=utf8"

  require 'mysql::bindings'
  require 'mysql::bindings::python'

  file { '/etc/mistral/mistral_dbsync.conf':
    ensure  => file,
    content => template('tesora_mistral/mistral_dbsync.conf.erb')
  }

  exec { 'tesora_mistral-dbsync-upgrade':
    command     => 'mistral-db-manage --config-file=/etc/mistral/mistral_dbsync.conf upgrade 011',
    path        => '/usr/bin',
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => File['/etc/mistral/mistral_dbsync.conf'],
  }

  exec { 'tesora_mistral-dbsync-populate':
    command     => 'mistral-db-manage --config-file=/etc/mistral/mistral_dbsync.conf populate',
    path        => '/usr/bin',
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
    subscribe   => File['/etc/mistral/mistral_dbsync.conf'],
  }

  File['/etc/mistral/mistral_dbsync.conf'] ->
    Exec['tesora_mistral-dbsync-upgrade'] ->
      Exec['tesora_mistral-dbsync-populate']
}

