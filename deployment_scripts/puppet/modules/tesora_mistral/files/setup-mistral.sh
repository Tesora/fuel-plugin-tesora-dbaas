#!/bin/bash
#
# Copyright (c) 2014 Tesora Inc.  All Rights Reserved.
#
# All use, reproduction, transfer, publication or disclosure is prohibited
# except as may be expressly permitted in the applicable license agreement.
#
# Version: DBAAS_FULL_VERSION


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

# must have /etc/mistral
[ -d /etc/mistral ] || { echo -e "Error: Directory not found: /etc/mistral\nIs Tesora DBaaS Workflow installed?"; exit 1; }

ini_has() {
    local file=$1
    local section=$2
    local option=$3

    found=$(sed -ne "/^\[$section\]/,/^\[.*\]/ { /^\(#\s*\)\?$option[ \t]*=/ p; }" "$file")
    [ -n "$found" ]
}

function ini_set {
    local file=$1
    local section=$2
    local option=$3
    local value=$4

    if ! grep -q "^\[$section\]" "$file" 2>/dev/null; then
        # append missing section
        echo -e "\n[$section]" >>"$file"
    fi

    if ini_has $file $section "$option"; then
        # replace it
        sed -i -e "/^\[$section\]/,/^\[.*\]/ s;^\(#\s*\)\?$option[ \t]*=.*;$option = $value;" "$file"
    else
        # add it
        sed -i -e "/^\[$section\]/ a\\
$option = $value
" "$file"
    fi
}


local_ip_address=$( hostname  -I | cut -f1 -d' ' )
local_hostname=$(hostname)

# URL that trove will register with keystone
opt_mistral_url="http://${local_hostname}:8989"

service mistral-api stop
service mistral-engine stop
service mistral-executor stop

database="mistral"
file=/etc/${database}/${database}.conf

db_hostport=${opt_mysqL_hostport}

# Database
db_host=$( echo $db_hostport | awk -F':' '{print $1}' )
db_port=$( echo $db_hostport | awk -F':' '{if ($2) print $2; else print 3306}' )
db_user=${opt_trove_mysql_user}
db_pass=${opt_trove_mysql_pass}
db_admin_user=${opt_mysql_admin_user}
db_admin_password=${opt_mysql_admin_pass}
db_admin_user=${opt_mysql_admin_user}
db_admin_password=${opt_mysql_admin_pass}

# Keystone
keystone_admin_url=$OS_AUTH_URL
keystone_unversioned_admin_url=$(echo $keystone_admin_url | sed 's/\(http[s]*:\/\/[0-9\.]*:[0-9]*\).*/\1/' )
keystone_host=$( echo $keystone_admin_url | sed -e "s/.*:\/\/\(.*\):[\0-9]\+.*/\1/" )
keystone_port=$( echo $keystone_admin_url | sed -e "s/.*:\/\/.*:\([\0-9]\+\).*/\1/" )
keystone_user=${opt_keystone_admin_user}
keystone_pass=${opt_keystone_admin_pass}

if [[ ${keystone_admin_url} == *v2.0 ]]; then
    LOCAL_KEYSTONE_VERSION=2
    LOCAL_KEYSTONE_VERSION_STR="v2.0"
else
    LOCAL_KEYSTONE_VERSION=3
    LOCAL_KEYSTONE_VERSION_STR="v3"
fi

# Assume for now that all services are running on the keystone host
opt_guest_keystone_host=${keystone_host}
opt_rabbit_host=${keystone_host}
opt_rabbit_port=${keystone_port}
opt_rabbit_user=${keystone_user}
opt_rabbit_pass=${keystone_pass}

keystone_public_url="$keystone_unversioned_public_url/$LOCAL_KEYSTONE_VERSION_STR"
keystone_unversioned_public_url=$(echo $keystone_public_url | sed 's/\(http[s]*:\/\/[0-9\.]*:[0-9]*\).*/\1/' )

# Mistral & Rabbitmq
mistral_admin_user=${opt_mistral_admin_user}
mistral_admin_password=${opt_mistral_admin_pass}

rabbit_host=${opt_rabbit_host}
rabbit_port=${opt_rabbit_port}
rabbit_userid=${opt_rabbit_user}
rabbit_password=${opt_rabbit_pass}


mistral_url=${opt_mistral_url}
mistral_endpoint="${mistral_url}/v2"

database="mistral"
file=/etc/${database}/${database}.conf

ini_set "$file" DEFAULT debug True
ini_set "$file" DEFAULT log_dir /var/log/mistral
ini_set "$file" DEFAULT log_file mistral.log

ini_set "$file" DEFAULT rpc_backend rabbit

ini_set "$file" oslo_messaging_rabbit rabbit_host ${rabbit_host}
ini_set "$file" oslo_messaging_rabbit rabbit_port ${rabbit_port}
ini_set "$file" oslo_messaging_rabbit rabbit_userid ${rabbit_userid}
ini_set "$file" oslo_messaging_rabbit rabbit_password ${rabbit_password}

sql_connection="mysql+pymysql://${db_user}:${db_pass}@${db_host}:${db_port}/${database}\?charset=utf8"
ini_set "$file" database connection $sql_connection

ini_set "$file" keystone_authtoken auth_uri $keystone_public_url
ini_set "$file" keystone_authtoken identity_uri $keystone_unversioned_admin_url
ini_set "$file" keystone_authtoken admin_user $mistral_admin_user
ini_set "$file" keystone_authtoken admin_password $mistral_admin_password

if [ -f /var/log/mistral/mistral.log ]; then
    chown mistral:mistral /var/log/mistral/mistral.log
fi
