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

if [ -s site_host_setup.sh ] ; then
    . site_host_setup.sh
fi

set_var HOSTS "${HOSTS:-''}"
set_var HOST_ADMIN "${HOST_ADMIN:-host_admin}"
set_var LOCAL_ADMIN "${LOCAL_ADMIN:-local_admin}"
set_var LOCAL_ADMIN_EMAIL "${LOCAL_ADMIN_EMAIL:-local_admin@example.com}"
set_var SITE "${SITE:-site}"
set_var SITE_USER "${SITE_USER:-site}"
set_var SITE_BASE_PORT "${SITE_BASE_PORT:-8000}"
set_var SITE_NUM_SERVERS "${SITE_NUM_SERVERS:-3}"

env | egrep 'SITE|HOST|LOCAL' | sort
echo "Hit Return to continue"
read rsp

# save setup
mv -f site_host_setup.sh site_host_setup.sh~
for x in HOSTS HOST_ADMIN LOCAL_ADMIN LOCAL_ADMIN_EMAIL SITE SITE_USER SITE_BASE_PORT SITE_NUM_SERVERS ; do
    eval "echo $x=\"'\$$x'\"" >>site_host_setup.sh
done

# start autotest
$@
