#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::install_mistral {
  package { 'tesora-mistral-api':          ensure => 'installed' }
  package { 'tesora-mistral-executor':     ensure => 'installed' }
  package { 'tesora-mistral-engine':       ensure => 'installed' }
  package { 'tesora-python-mistralclient': ensure => 'installed' }
}
