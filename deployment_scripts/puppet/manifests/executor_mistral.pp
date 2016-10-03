#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral executor_mistral.pp')

class tesora_mistral::executor_mistral {

  class { '::mistral::executor': }
  Mistral_config <||> ~> Service[$::mistral::params::executor_service_name]
  Package['mistral-executor'] -> Service[$::mistral::params::executor_service_name]
  Package['mistral-executor'] -> Service['mistral-executor']
}

class {'tesora_mistral::executor_mistral':}
