#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_mistral dashboard_mistral.pp')

class tesora_mistral::dashboard_mistral {

  include ::horizon::params

  package { 'python-pip':
    ensure => installed,
  } ->
  package { 'python-dev':
    ensure => installed,
  } ->
  package { 'mistral-dashboard':
    ensure   => $tesora_mistral::dashboard_version,
    name     => $tesora_mistral::dashboard_name,
    provider => pip,
  } ->
  file { $tesora_mistral::horizon_ext_file:
    ensure  => file,
    content => template('tesora_mistral/_50_mistral.py.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  } ~>
  service { $horizon::params::http_service:
    ensure => running,
  }
}

class { 'tesora_mistral::dashboard_mistral': }
