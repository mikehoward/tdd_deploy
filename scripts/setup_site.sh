#! /bin/sh

# Functions

fail() {
    echo $*
    exit 1
}

ssh_it() {
    HOST=$1 ; shift
    ssh root@${HOST} $@
}

# parse Args

hlp="
Usage: `basename $0` [-h | options] remote_host [remote_host . . .]

Option              Meaning
-s/--site <sitename>      name of site. must satisfy [a-z][-a-z]* (required)
-u/--user <site user>     name of user ([a-z]+) (optional)
-p/--password <password>  password for user (.{8,}) (required)
-d/--dbname  <db name>    name of database ([a-z][a-z0-9_]*) (optional)
-t/--test                 run unit test
"

while [ $# -gt 0 ] ; do
    case $1 in
	-h|--help) echo "${hlp}" ; exit ;;
	-s|--site) SITE=$1 ; shift ; shift ;;
	-u|--user) USERNAME=$2 ; shift ; shift ;;
	-p|--password) PASSWORD=$2 ; shift ; shift ;;
	-d|--dbname) DATABASE=$2 ; shift ; shift ;;
	-t|--test) TEST=true ; shift ; ;;
	*) REMOTE_HOST_LIST=$@ ; break ;;
    esac
done

if [ "${TEST}" = 'true' ] ; then
    REMOTE_HOST_LIST='arch ubuntu'
    SITE=test_site
    PASSWORD=password
    USERNAME=test_site
    DATABASE=test_site
else
    test -z "${REMOTE_HOST_LIST}" && fail "you must define the remote host\n${hlp}"
    test -z "${SITE}" && fail "you must define the site name ([a-z][-a-z]*)"
    test -z "${PASSWORD}" && fail "you must define a password for the site user"
    test -z "${USERNAME}" && USERNAME="${SITE}"
    test -z "${DATABASE}" && DATABASE="${SITE}"
fi

# verify root works on all sites
for HOST in ${REMOTE_HOST_LIST} ; do
    ssh root@${HOST} pwd || fail "Unable to execute as root on ${HOST}"
done

# create USERNAME on all sites it does not exist on
for HOST in ${REMOTE_HOST_LIST} ; do
    if ssh root@${HOST} test -d /home/${USERNAME} ; then
	msg "${USERNAME} already exists on host ${HOST}"
    else
	ssh root@${HOST} useradd -u -p ${PASSWORD} ${USERNAME} \
	    && msg "Created ${USERNAME} on host ${HOST}"
	    || msg "Unable to Create ${USERNAME} on host ${HOST}"
    fi
done


# create database for site on all sites it does not exist on
for HOST in ${REMOTE_HOST_LIST} ; do
    if ssh root@${HOST} test -d /home/${USERNAME} ; then
	msg "${USERNAME} already exists on host ${HOST}"
    else
	ssh root@${HOST} useradd -u -p ${PASSWORD} ${USERNAME} \
	    && msg "Created ${USERNAME} on host ${HOST}"
	    || msg "Unable to Create ${USERNAME} on host ${HOST}"
    fi
done

