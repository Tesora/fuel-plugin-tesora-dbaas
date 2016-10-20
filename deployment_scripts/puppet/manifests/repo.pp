# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas repo.pp')

apt::pin { 'fuel-plugin-tesora-dbaas-1.9.4':
    priority        => 1100,
    label           => 'fuel-plugin-tesora-dbaas',
    release_version => '1.9',
}
