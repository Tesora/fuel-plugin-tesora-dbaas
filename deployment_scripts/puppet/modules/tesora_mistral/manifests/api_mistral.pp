#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::api {

  class { '::mistral::api':
    bind_host => $tesora_mistral::bind_host,
  }

}
