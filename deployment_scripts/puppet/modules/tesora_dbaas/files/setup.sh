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
service trove-api stop
service trove-taskmanager stop
service trove-conductor stop

# Look in setup.cfg.erb and configure.pp files
# if you're curious what this URL variable is
db_hostport=${opt_mysql_hostport}

# Database
db_host=$( echo $db_hostport | awk -F':' '{print $1}' )
db_port=$( echo $db_hostport | awk -F':' '{if ($2) print $2; else print 3306}' )
db_user=${opt_trove_mysql_user}
db_pass=${opt_trove_mysql_pass}
db_admin_user=${opt_mysql_admin_user}
db_admin_password=${opt_mysql_admin_pass}

# Keystone
keystone_admin_url=${opt_keystone_admin_url}
keystone_public_url=${opt_keystone_public_url}
keystone_admin_user=${opt_keystone_admin_user}
keystone_admin_password=${opt_keystone_admin_pass}
keystone_admin_tenant=${opt_keystone_admin_tenant}

# This removes the version (v2.0, v3) from the url
keystone_public_unversioned=$(echo $keystone_public_url | sed 's/\(http[s]*:\/\/[0-9\.]*:[0-9]*\).*/\1/' )
keystone_admin_unversioned=$(echo $keystone_admin_url | sed 's/\(http[s]*:\/\/[0-9\.]*:[0-9]*\).*/\1/' )

# Rabbit
rabbit_hosts=${opt_rabbit_hosts}
rabbit_userid=${opt_rabbit_user}
rabbit_password=${opt_rabbit_pass}
guest_rabbit_hosts=${opt_guest_rabbit_hosts}

# Trove
trove_user=${opt_trove_admin_user}
trove_password=${opt_trove_admin_pass}
trove_tenant=${opt_trove_admin_tenant}
trove_region=${opt_trove_region}
trove_public_url=${opt_trove_public_url}
trove_admin_url=${opt_trove_admin_url}

# Tailor configuration files
for file in /etc/trove/trove.conf /etc/trove/trove-taskmanager.conf /etc/trove/trove-conductor.conf /etc/trove/trove-guestagent.conf; do
    # set OpenStack credentials
    ini_set "$file" DEFAULT rpc_backend rabbit
    ini_set "$file" DEFAULT trove_auth_url ${keystone_admin_url}
    ini_set "$file" DEFAULT bind_host ${opt_trove_bind_host}
    [ -n "${trove_region}" ] && ini_set "$file" DEFAULT os_region_name $trove_region

    # set messaging credentials
    ini_set "$file" oslo_messaging_rabbit rabbit_hosts ${rabbit_hosts}
    ini_set "$file" oslo_messaging_rabbit rabbit_userid ${rabbit_userid}
    ini_set "$file" oslo_messaging_rabbit rabbit_password ${rabbit_password}

    if [[ ! $file =~ "trove-guestagent" ]]
    then
        sql_connection="mysql+pymysql://${db_user}:${db_pass}@${db_hostport}/trove\?charset=utf8"
        ini_set "$file" database connection ${sql_connection}
    fi
done

file=/etc/trove/trove-guestagent.conf
ini_set "$file" DEFAULT trove_auth_url ${keystone_public_url}
ini_set "$file" oslo_messaging_rabbit rabbit_hosts ${guest_rabbit_hosts}

file=/etc/trove/trove.conf
ini_set "$file" keystone_authtoken identity_uri ${keystone_admin_unversioned}
ini_set "$file" keystone_authtoken auth_uri ${keystone_public_unversioned}
ini_set "$file" keystone_authtoken admin_tenant_name ${trove_tenant}
ini_set "$file" keystone_authtoken admin_password ${trove_password}
ini_set "$file" keystone_authtoken admin_user ${trove_user}

# Get information out of keystone and put in trove conf files.
function keystone_cmd {
    keystone --os-username $keystone_admin_user --os-password $keystone_admin_password --os-tenant-name $keystone_admin_tenant --os-auth-url $keystone_admin_url "$@"
}
export -f keystone_cmd

if [ -f /var/log/trove/trove-api.log ]; then
    chown trove:trove /var/log/trove/trove-api.log
fi
