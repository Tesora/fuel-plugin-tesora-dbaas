#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#

notice('tesora_dbaas cluster.pp')

$network_scheme = hiera_hash('network_scheme', {})
$network_metadata = hiera_hash('network_metadata', {})

prepare_network_config($network_scheme)

$trove_node       = get_nodes_hash_by_roles($network_metadata, ['tesora-dbaas'])

$corosync_nodes   = corosync_nodes($trove_node, 'trove/api')

$network_ip       = get_network_role_property('trove/api', 'ipaddr')

$corosync_nodes_processed = corosync_nodes_process($corosync_nodes)

class { '::cluster':
  internal_address         => get_network_role_property('trove/api', 'ipaddr'),
  quorum_members           => $corosync_nodes_processed['ips'],
  unicast_addresses        => $corosync_nodes_processed['ips'],
  quorum_members_ids       => $corosync_nodes_processed['ids'],
  cluster_recheck_interval => $cluster_recheck_interval,
}

pcmk_nodes { 'pacemaker' :
  nodes               => $corosync_nodes,
  add_pacemaker_nodes => false,
}

Service <| title == 'corosync' |> {
  subscribe => File['/etc/corosync/service.d'],
  require   => File['/etc/corosync/corosync.conf'],
}

Service['corosync'] -> Pcmk_nodes<||>
Pcmk_nodes<||> -> Service<| provider == 'pacemaker' |>

# Sometimes during first start pacemaker can not connect to corosync
# via IPC due to pacemaker and corosync processes are run under different users
if($::operatingsystem == 'Ubuntu') {
  $pacemaker_run_uid = 'hacluster'
  $pacemaker_run_gid = 'haclient'

  file {'/etc/corosync/uidgid.d/pacemaker':
    content =>"uidgid {
   uid: ${pacemaker_run_uid}
   gid: ${pacemaker_run_gid}
}"
  }

  File['/etc/corosync/corosync.conf'] -> File['/etc/corosync/uidgid.d/pacemaker'] -> Service <| title == 'corosync' |>
}
