#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas install_horizon.pp')

package { 'tesora-dbaas-dashboard':         ensure => 'installed' }
