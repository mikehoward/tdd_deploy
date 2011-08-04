#! /bin/sh

# set up environment
# export HOSTS=""
set_var() {
    echo "Value for ${1} [$2]: \c"
    read rsp
    if [ -n "$rsp" ] ; then
	eval export $1='"$rsp"'
    else
	eval export $1='"$2"'
    fi
}

set_var HOST_ADMIN host_admin
set_var LOCAL_ADMIN local_admin
set_var LOCAL_ADMIN_EMAIL local_admin@example.com
set_var SITE site
set_var SITE_USER site
set_var SITE_BASE_PORT 8000
set_var SITE_NUM_SERVERS 3

env | sort

# start autotest
autotest