#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('MODULAR: tesora_mistral/api_mistral.pp')

include tesora_mistral

class {'tesora_mistral::api':}