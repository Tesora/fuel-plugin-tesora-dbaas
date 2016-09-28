#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral engine.pp')

class tesora_mistral::engine {

  class { '::mistral::engine': }

  Mistral_config <||> ~> Service[$::mistral::params::engine_service_name]
  Package['mistral-engine'] -> Service[$::mistral::params::engine_service_name]
  Package['mistral-engine'] -> Service['mistral-engine']
}
