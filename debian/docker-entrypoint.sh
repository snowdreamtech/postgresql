#!/bin/sh

set -e

# Modify from https://salsa.debian.org/postgresql/postgresql-common/-/blob/master/debian/init.d-functions
#
#
#
# This file contains common functionality for all postgresql server
# package init.d scripts. It is usually included by
# /etc/init.d/postgresql

user="postgres"
group="postgres"

init_functions=/lib/lsb/init-functions
#redhat# init_functions=/usr/share/postgresql-common/init-functions-compat
. $init_functions

PGBINROOT="/usr/lib/postgresql/"
#redhat# PGBINROOT="/usr/pgsql-"
pg_version=$(ls $PGBINROOT 2>/dev/null)

# do pg_ctlcluster action $1 to all clusters of version $2 with command
# description $3; output according to Debian Policy for init scripts
do_ctl_all() {
    [ "$1" ] || { echo "Error: invalid command '$1'" >&2; exit 1; }
    [ "$2" ] || { echo "Error: invalid version '$2'" >&2; exit 1; }
    [ -d "/etc/postgresql/$2" ] || return 0
    [ "$(ls /etc/postgresql/$2)" ] || return 0
    [ -x "$PGBINROOT$2/bin/postgres" ] || return 0

    status=0
    log_daemon_msg "$3"
    for c in /etc/postgresql/"$2"/*; do
	[ -e "$c/postgresql.conf" ] || continue
	name=$(basename "$c")

	# evaluate start.conf
	if [ -e "$c/start.conf" ]; then
	    start=$(sed 's/#.*$//; /^[[:space:]]*$/d; s/^\s*//; s/\s*$//' "$c/start.conf")
	else
	    start=auto
	fi
	[ "$start" = "auto" ] || continue

        log_progress_msg "$name"
	set +e
	if [ "$1" = "stop" ] || [ "$1" = "restart" ]; then
	    ERRMSG=$(pg_ctlcluster --force "$2" "$name" $1 2>&1)
	else
	    ERRMSG=$(pg_ctlcluster "$2" "$name" $1 2>&1)
	fi
	res=$?
	set -e
	# Do not fail on success or if cluster is already/not running
	[ $res -eq 0 ] || [ $res -eq 2 ] || status=$(($status || $res))
    done
    if [ $status -ne 0 -a -n "$ERRMSG" ]; then
	log_failure_msg "$ERRMSG"
    fi
    log_end_msg $status
    return $status
}

# create /var/run/postgresql
create_socket_directory() {
    if [ -d /var/run/postgresql ]; then
	chmod 2775 /var/run/postgresql
    else
	install -d -m 2775 -o postgres -g postgres /var/run/postgresql
	[ -x /sbin/restorecon ] && restorecon -R /var/run/postgresql || true
    fi
}

# start all clusters of version $1
# output according to Debian Policy for init scripts
start() {
    do_ctl_all start "$1" "Starting PostgreSQL $1 database server"
}

# stop all clusters of version $1
# output according to Debian Policy for init scripts
stop() {
    do_ctl_all stop "$1" "Stopping PostgreSQL $1 database server"
}

# restart all clusters of version $1
# output according to Debian Policy for init scripts
restart() {
    do_ctl_all restart "$1" "Restarting PostgreSQL $1 database server"
}

# reload all clusters of version $1
# output according to Debian Policy for init scripts
reload() {
    do_ctl_all reload "$1" "Reloading PostgreSQL $1 database server"
}

status() {
    CLUSTERS=`pg_lsclusters -h | grep "^$1[[:space:]]"`
    # no clusters -> unknown status
    [ -n "$CLUSTERS" ] || exit 4
    echo "$CLUSTERS" | awk 'BEGIN {rc=0; printf("Running clusters: ")} {if (match($4, "online")) printf ("%s/%s ", $1, $2); else rc=3} END { printf("\n"); exit rc }'
}

# return all installed versions which do not have their own init script
get_versions() {
    versions=''
    local v dir skipinit

    skipinit=continue
    #redhat# skipinit=true # RedHat systems will have /etc/init.d/postgresql-* provided by the yum.pg.o package
    dir=$PGBINROOT
    #redhat# dir="-d /usr/pgsql-*"

    for v in `ls $dir 2>/dev/null`; do
        #redhat# v=${v#*-}
        [ -x /etc/init.d/postgresql-$v ] && $skipinit
        if [ -x $PGBINROOT$v/bin/pg_ctl ]; then
	    versions="$versions $v"
	fi
    done
}

psql_command() {
	su $user -c "psql --no-psqlrc --no-align --tuples-only -q -c \"$1\""
}

# Custom scripts
modify_root_password() {
	if [ -n "${POSTGRES_ROOT_PASSWORD}" ]; then
		{
			out=$(psql_command "ALTER USER postgres WITH PASSWORD '${POSTGRES_ROOT_PASSWORD}';")

			if [ "$out" ]; then
				for line in $out; do
					echo "  $line"
				done
			fi

			if [ $? -eq 0 ]; then
				return 0
			else
				return 1
			fi
		}
	fi
}

create_user_if_not_exist() {
	if [ -n "${POSTGRES_USER}" ]; then
		userAlreadyExists=$(psql_command "SELECT 1 FROM pg_user WHERE usename='${POSTGRES_USER}';")

		if [ "${userAlreadyExists}" ] && [ "${userAlreadyExists}" -eq 1 ]; then
			echo "user ${POSTGRES_USER} has already exists."
		else
			if [ -z "${POSTGRES_PASSWORD}" ]; then
				POSTGRES_PASSWORD=$(openssl rand -base64 33)
				echo "generate random password for user ${POSTGRES_USER} : ${POSTGRES_PASSWORD}"
			fi

			userCreatedResult=$(psql_command "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';")

			if [ -z "${userCreatedResult}" ]; then
				echo "user ${POSTGRES_USER} has been created with your password."
			fi
		fi
	fi
}

create_database_if_not_exist() {
	if [ -n "${POSTGRES_DB}" ]; then
		dbAlreadyExists=$(psql_command "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';")

		if [ "${dbAlreadyExists}" ] && [ "${dbAlreadyExists}" -eq 1 ]; then
			echo "database ${POSTGRES_DB} has already exists."
		else
			dbCreatedResult=$(psql_command "CREATE DATABASE ${POSTGRES_DB};")

			if [ -z "${dbCreatedResult}" ]; then
				echo "database ${POSTGRES_DB} has been created."
			fi
		fi
	fi
}

create_user_and_database_if_not_exist() {
	create_user_if_not_exist

	if [ -n "${POSTGRES_DB}" ]; then
		dbAlreadyExists=$(psql_command "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';")

		if [ "${dbAlreadyExists}" ] && [ "${dbAlreadyExists}" -eq 1 ]; then
			echo "database ${POSTGRES_DB} has already exists."
		else
			dbCreatedResult=$(psql_command "CREATE DATABASE ${POSTGRES_DB};")

			if [ -z "${dbCreatedResult}" ]; then
				echo "database ${POSTGRES_DB} has been created."

				dbGrantdResult=$(psql_command "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};")

				if [ -z "${dbGrantdResult}" ]; then
					echo "grant all privileges on database ${POSTGRES_DB} to ${POSTGRES_USER}."
				fi
			fi
		fi
	fi
}

# postgres
create_socket_directory

POSTGRES_CONFIG_PATH="/etc/postgresql/$pg_version/main"
POSTGRES_DATABASE_CONFIG_PATH="${POSTGRES_CONFIG_PATH}/postgresql.conf"
POSTGRES_HBA_CONFIG_PATH="${POSTGRES_CONFIG_PATH}/pg_hba.conf"

# openssl rand -base64 33
if [ -z "${POSTGRES_ROOT_PASSWORD}" ]; then
	{
		POSTGRES_ROOT_PASSWORD=$(openssl rand -base64 33)
		echo "generate random password for user postgres : ${POSTGRES_ROOT_PASSWORD}"
	}
fi

# Modifying configuration file postgresql.conf
# https://wiki.alpinelinux.org/wiki/Postgresql
# https://wiki.alpinelinux.org/wiki/Postgresql_16
if [ "${POSTGRES_DISALLOW_USER_LOGIN_REMOTELY}" -eq 0 ]; then
	{
		sed -i "s|\#*listen_addresses\s*=\s*'localhost'|listen_addresses = '*'|g" ${POSTGRES_DATABASE_CONFIG_PATH}
	}
fi

if [ "${POSTGRES_PORT}" -gt 0 ]; then
	{
		sed -i "s|\#*port\s*=\s*[0-9]+|port = ${POSTGRES_PORT}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
	}
fi

if [ -n "${POSTGRES_HOST_AUTH_METHOD}" ] && [ "${POSTGRES_HOST_AUTH_METHOD}" != "trust" ]; then
	{
		sed -i "s|\#*password_encryption\s*=\s*scram-sha-256\|md5\|password|password_encryption = ${POSTGRES_HOST_AUTH_METHOD}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
	}
fi

if [ "${POSTGRES_MAX_CONNECTIONS}" -gt 0 ]; then
	{
		sed -i "s|\#*max_connections\s*=\s*[0-9]+|max_connections = ${POSTGRES_MAX_CONNECTIONS}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
	}
fi

# Modifying configuration file pg_hba.conf
# https://wiki.alpinelinux.org/wiki/Postgresql_16
if [ "${POSTGRES_DISALLOW_USER_LOGIN_REMOTELY}" -eq 0 ]; then
	{
		sed -i "/^\s*host\s*all\s*all\s*0\.0\.0\.0\/0\s*${POSTGRES_HOST_AUTH_METHOD}/d" "${POSTGRES_HBA_CONFIG_PATH}"
		echo "host    all             all             0.0.0.0/0               ${POSTGRES_HOST_AUTH_METHOD}" >>"${POSTGRES_HBA_CONFIG_PATH}"
	}
fi

# postgres
start "$pg_version"
modify_root_password
create_user_and_database_if_not_exist

# exec commands
if [ -n "$*" ]; then
	sh -c "$*"
fi

# keep the docker container running
# https://github.com/docker/compose/issues/1926#issuecomment-422351028
if [ "${KEEPALIVE}" -eq 1 ]; then
	trap "stop $pg_version" TERM INT
	tail -f /dev/null &
	wait
	# sleep infinity & wait
fi
