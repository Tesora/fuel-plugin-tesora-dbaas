#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

class tesora_mistral::vip {

  openstack::ha::haproxy_service { 'mistral-api':
    internal_virtual_ip    => $tesora_mistral::management_vip,
    listen_port            => $tesora_mistral::port,
    order                  => '300',
    public_virtual_ip      => $tesora_mistral::public_vip,
    internal               => true,
    public                 => true,
    ipaddresses            => $tesora_mistral::mistral_api_nodes_ips,
    server_names           => $tesora_mistral::mistral_api_nodes_ips,
    public_ssl             => $tesora_mistral::public_ssl,
    public_ssl_path        => $tesora_mistral::public_ssl_path,
    haproxy_config_options => {
        option         => ['httpchk', 'httplog', 'httpclose'],
        'http-request' => 'set-header X-Forwarded-Proto https if { ssl_fc }',
    },
    balancermember_options => 'check inter 10s fastinter 2s downinter 3s rise 3 fall 3',
  }

  firewall { '300 mistral':
    chain  => 'INPUT',
    dport  => $tesora_mistral::port,
    proto  => 'tcp',
    action => 'accept',
  }

}
