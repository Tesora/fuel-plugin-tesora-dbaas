#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_dbaas::start_services {

  Service { ensure => running, enable => true }

  if $::operatingsystem == 'Ubuntu' {
    service { 'trove-api': }
    service { 'trove-taskmanager': }
    service { 'trove-conductor': }
  }
  else {
    service { 'openstack-trove-api': }
    service { 'openstack-trove-taskmanager': }
    service { 'openstack-trove-conductor': }
  }
}
