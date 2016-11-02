#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::install {
  package { 'tesora-dbaas-api':         ensure => 'installed' }
  package { 'tesora-dbaas-taskmanager': ensure => 'installed' }
  package { 'tesora-dbaas-conductor':   ensure => 'installed' }
  package { 'tesora-dbaas-client':      ensure => 'installed' }

  service { 'trove-api':
    ensure  => stopped,
    require => Package['tesora-dbaas-api']
  }
  service { 'trove-taskmanager':
    ensure  => stopped,
    require => Package['tesora-dbaas-taskmanager']
  }
  service { 'trove-conductor':
    ensure  => stopped,
    require => Package['tesora-dbaas-conductor']
  }

}
