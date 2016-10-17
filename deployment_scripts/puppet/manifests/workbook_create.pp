notice('workbook_create.pp')

exec { 'trove-workbook-create':
  command   => "/bin/bash -c 'source /opt/tesora/dbaas/bin/openrc.sh && /usr/bin/openstack --debug workbook create  /etc/trove/trove-workbook.yaml ; true'",
  logoutput => true
}
