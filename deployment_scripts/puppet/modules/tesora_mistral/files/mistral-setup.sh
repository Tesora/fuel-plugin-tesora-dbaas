#!/bin/bash
#
# Copyright (c) 2016 Tesora Inc.  All Rights Reserved.
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

# must have /etc/mistral
[ -d /etc/mistral ] || { echo -e "Error: Directory not found: /etc/mistral\nIs Tesora DBaaS Workflow installed?"; exit 1; }

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


# Shut down Tesora Mistral services to avoid resource errors
service mistral-api stop
service mistral-engine stop
service mistral-executor stop

db_hostport=${opt_mysql_hostport}

# Database
db_host=$( echo $db_hostport | awk -F':' '{print $1}' )
db_port=$( echo $db_hostport | awk -F':' '{if ($2) print $2; else print 3306}' )
db_user=${opt_mistral_mysql_user}
db_pass=${opt_mistral_mysql_pass}

# Keystone
keystone_admin_url=${opt_keystone_admin_url}
keystone_public_url=${opt_keystone_public_url}
keystone_admin_port=$( echo $keystone_admin_url | sed -e "s/.*:\/\/.*:\([\0-9]\+\).*/\1/" )
keystone_admin_user=${opt_keystone_admin_user}
keystone_admin_password=${opt_keystone_admin_pass}
keystone_admin_tenant=${opt_keystone_admin_tenant}

# This removes the version (v2.0, v3) from the url
keystone_unversioned_admin_url=$(echo $keystone_admin_url | sed 's/\(http[s]*:\/\/[0-9\.]*:[0-9]*\).*/\1/' )

if [[ ${keystone_admin_url} == *v2.0 ]]; then
    local_keystone_version=2
    local_keystone_version_str="v2.0"
elif [[ ${keystone_admin_url} == *v3 ]]; then
    local_keystone_version=3
    local_keystone_version_str="v3"
else
    echo "Attempt to detect keystone version from '${keystone_admin_url}'" failed.
    echo "Please check your environment settings and try again"
fi

# Rabbit
rabbit_hosts=${opt_rabbit_hosts}
rabbit_userid=${opt_rabbit_user}
rabbit_password=${opt_rabbit_pass}

# Mistral
mistral_user=${opt_mistral_admin_user}
mistral_password=${opt_mistral_admin_pass}
mistral_tenant=${opt_mistral_admin_tenant}
mistral_region=${opt_mistral_region}
mistral_public_url=${opt_mistral_public_url}
mistral_admin_url=${opt_mistral_admin_url}


# Tailor configuration files

file=/etc/mistral/mistral.conf
ini_set "$file" DEFAULT debug False
ini_set "$file" DEFAULT log_dir /var/log/mistral
ini_set "$file" DEFAULT log_file mistral.log
ini_set "$file" DEFAULT rpc_backend rabbit
ini_set "$file" DEFAULT bind_host $opt_mistral_bind_host

ini_set "$file" oslo_messaging_rabbit rabbit_hosts ${rabbit_hosts}
ini_set "$file" oslo_messaging_rabbit rabbit_password ${rabbit_password}

# Mistral rabbit only works when it has the same username as we did for tesora_dbaas/rabbitmq
ini_set "$file" oslo_messaging_rabbit rabbit_userid "trove"

sql_connection="mysql+pymysql://${db_user}:${db_pass}@${db_host}:${db_port}/mistral\?charset=utf8"
ini_set "$file" database connection $sql_connection

ini_set "$file" keystone_authtoken auth_host ${opt_controller_host}
ini_set "$file" keystone_authtoken identity_uri ${keystone_unversioned_admin_url}
ini_set "$file" keystone_authtoken auth_port ${keystone_admin_port}
ini_set "$file" keystone_authtoken admin_tenant_name ${mistral_tenant}
ini_set "$file" keystone_authtoken admin_user ${mistral_user}
ini_set "$file" keystone_authtoken admin_password ${mistral_password}
ini_set "$file" keystone_authtoken auth_version ${local_keystone_version_str}


if [ -f /var/log/mistral/mistral.log ]; then
    chown mistral:mistral /var/log/mistral/mistral.log
fi
