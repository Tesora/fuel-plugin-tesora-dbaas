#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral repo_mistral.pp')

class tesora_mistral::repo_mistral {

  include apt

  apt::pin { 'fuel-plugin-mistral-tesora-dbaas-1.9.0':
    priority        => 1100,
    label           => 'fuel-plugin-mistral-tesora-dbaas',
    release_version => '1.9',
  }

}
