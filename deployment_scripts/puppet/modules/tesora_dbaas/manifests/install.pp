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
}
