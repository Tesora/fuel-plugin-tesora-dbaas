#!/bin/bash -x
#
# Copyright (c) 2014 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#


if [ $# -eq 2 ]
then
    source $1
    is_primary=$2
else
    echo "Illegal number of parameters"
    echo "please pass config file and is_primary flag"
    exit 1
fi

# must be root
[ "$(id -u)" != "0" ] && { echo "Sorry, you are not root."; exit 1; }

# must have /etc/trove
[ -d /etc/trove ] || { echo -e "Directory not found: /etc/trove\nIs Tesora DBaaS installed?"; exit 1; }


function command_exists {
    command -v "$1" &> /dev/null;
}

ini_has() {
    local file=$1
    local section=$2
    local option=$3

    # check for existing option
    found=$(sed -ne "/^\[$section\]/,/^\[.*\]/ { /^\s*$option[ \t]*=/ p; }" "$file")
    [ -n "$found" ]
}

function ini_set {
    local file=$1
    local section=$2
    local option=$3
    local value=$4

    if ! grep -q "^\[$section\]" "$file" 2>/dev/null
    then
        # append missing section
        echo -e "\n[$section]" >>"$file"
    fi

    if ini_has $file $section $option
    then
        # replace it
        sed -i -e "/^\[$section\]/,/^\[.*\]/ s;^\(\s*\)\?$option[ \t]*=.*;$option = $value;" "$file"
    else
        # add it
        sed -i -e "/^\[$section\]/ a\\
$option = $value
" "$file"
    fi
}

# Shut down Tesora DBaaS to avoid resource errors
if [ -f "/etc/debian_version" ]
then
    service trove-api stop
    service trove-taskmanager stop
    service trove-conductor stop
else
    service openstack-trove-api stop
    service openstack-trove-taskmanager stop
    service openstack-trove-conductor stop
fi

db_hostport=${opt_mysqL_hostport}

db_host=$( echo $db_hostport | awk -F':' '{print $1}' )
db_port=$( echo $db_hostport | awk -F':' '{if ($2) print $2; else print 3306}' )
db_user=${opt_trove_mysql_user}
db_pass=${opt_trove_mysql_pass}

db_admin_user=${opt_mysql_admin_user}
db_admin_password=${opt_mysql_admin_pass}

sql_connection="mysql://$db_user:$db_pass@$db_hostport/trove\?charset=utf8"

trove_user=${opt_trove_admin_user}
trove_password=${opt_trove_admin_pass}
trove_tenant=${opt_trove_admin_tenant}
trove_region=${opt_trove_region}

keystone_admin_url=${opt_keystone_admin_url}
keystone_public_url=${opt_keystone_public_url}
echo "BRIAN ${opt_keystone_public_url} ${keystone_public_url}"
keystone_admin_port=$( echo $keystone_admin_url | sed -e "s/.*:\/\/.*:\([\0-9]\+\).*/\1/" )
keystone_admin_user=${opt_keystone_admin_user}
keystone_admin_password=${opt_keystone_admin_pass}
keystone_admin_tenant=${opt_keystone_admin_tenant}

nova_url=${opt_nova_url}
nova_user=${opt_nova_user}
nova_password=${opt_nova_pass}
nova_tenant=${opt_nova_tenant}

cinder_url=${opt_cinder_url}

swift_admin_url="${opt_swift_admin_url}/AUTH_"
swift_public_url="${opt_swift_public_url}/AUTH_"

rabbit_hosts=${opt_rabbit_hosts}
rabbit_userid=${opt_rabbit_user}
rabbit_password=${opt_rabbit_pass}

guest_rabbit_hosts="$opt_guest_rabbit_hosts"

trove_user=${opt_trove_admin_user}
trove_password=${opt_trove_admin_pass}
trove_tenant=${opt_trove_admin_tenant}

trove_public_url=${opt_trove_public_url}
trove_admin_url=${opt_trove_admin_url}

trove_public_endpoint="${trove_public_url}/v1.0/\$(tenant_id)s"
trove_admin_endpoint="${trove_admin_url}/v1.0/\$(tenant_id)s"


# Tailor configuration files

for file in /etc/trove/trove.conf /etc/trove/trove-taskmanager.conf /etc/trove/trove-conductor.conf /etc/trove/trove-guestagent.conf; do
    # set messaging credentials
    ini_set "$file" oslo_messaging_rabbit rabbit_hosts "$rabbit_hosts"
    ini_set "$file" oslo_messaging_rabbit rabbit_userid $rabbit_userid
    ini_set "$file" oslo_messaging_rabbit rabbit_password $rabbit_password

    # set OpenStack credentials
    ini_set "$file" DEFAULT nova_proxy_admin_user $nova_user
    ini_set "$file" DEFAULT nova_proxy_admin_pass $nova_password
    ini_set "$file" DEFAULT trove_auth_url $keystone_admin_url

    ini_set "$file" DEFAULT swift_url $swift_admin_url

    [ -n "${trove_region}" ] && ini_set "$file" DEFAULT os_region_name $trove_region

    # set these for everything EXCEPT the guest agent
    if [[ ! $file =~ "trove-guestagent" ]]
    then
        ini_set "$file" database connection $sql_connection
        ini_set "$file" DEFAULT nova_compute_url $nova_url
        ini_set "$file" DEFAULT cinder_url $cinder_url

        [ -n "${opt_use_nova_key_name}" ] && ini_set "$file" DEFAULT use_nova_key_name $opt_use_nova_key_name
        [ -n "${opt_use_nova_server_config_drive}" ] && ini_set "$file" DEFAULT use_nova_server_config_drive $opt_use_nova_server_config_drive
        [ -n "${opt_network_driver}" ] && ini_set "$file" DEFAULT network_driver $opt_network_driver
        [ -n "${opt_cinder_service_type}" ] && ini_set "$file" DEFAULT cinder_service_type $opt_cinder_service_type
        [ -n "${opt_network_label_regex}" ] && ini_set "$file" DEFAULT network_label_regex $opt_network_label_regex
    fi
done

file=/etc/trove/trove-guestagent.conf
ini_set "$file" DEFAULT trove_auth_url "$keystone_public_url"
ini_set "$file" DEFAULT swift_url "$swift_public_url"
ini_set "$file" oslo_messaging_rabbit rabbit_hosts "$guest_rabbit_hosts"

file=/etc/trove/trove.conf
ini_set "$file" DEFAULT bind_host $opt_trove_bind_host

ini_set "$file" keystone_authtoken auth_host $opt_controller_host
ini_set "$file" keystone_authtoken auth_port $keystone_admin_port
ini_set "$file" keystone_authtoken auth_protocol http
ini_set "$file" keystone_authtoken admin_tenant_name $trove_tenant
ini_set "$file" keystone_authtoken admin_user $trove_user
ini_set "$file" keystone_authtoken admin_password $trove_password
ini_set "$file" keystone_authtoken auth_version v2.0
[ -n "${opt_auth_protocol}" ] && ini_set "$file" keystone_authtoken auth_protocol $opt_auth_protocol


# Get information out of keystone and put in trove conf files.
function keystone_cmd {
    keystone --os-username $keystone_admin_user --os-password $keystone_admin_password --os-tenant-name $keystone_admin_tenant --os-auth-url $keystone_admin_url "$@"
}
export -f keystone_cmd

# Get the id for the admin tenant from keystone and add to trove-taskmanager.conf
nova_proxy_admin_tenant_id=$( keystone_cmd tenant-get $nova_tenant | awk '/\ id\ / {print $4}' )
ini_set /etc/trove/trove-taskmanager.conf DEFAULT nova_proxy_admin_tenant_id "${nova_proxy_admin_tenant_id}"
ini_set /etc/trove/trove.conf DEFAULT nova_proxy_admin_tenant_id "${nova_proxy_admin_tenant_id}"

chown trove:trove /var/log/trove/trove-api.log
