#!/bin/sh
set -e

if [ "$DEBUG" = "true" ]; then echo "→ [postgresql] Starting postgresql..."; fi

user="postgres"
group="postgres"

# Rocky specific paths
data_dir="/var/lib/pgsql/data"
conf_dir="$data_dir"
logfile="/var/lib/pgsql/postmaster.log"
port=5432

conffile="$conf_dir/postgresql.conf"
pidfile="$data_dir/postmaster.pid"

psql_command() {
	su $user -c "psql --no-psqlrc --no-align --tuples-only -q -c \"$1\""
}

modify_root_password() {
	if [ -n "${POSTGRES_ROOT_PWD}" ]; then
		out=$(psql_command "ALTER USER postgres WITH PASSWORD '${POSTGRES_ROOT_PWD}';")
		if [ "$out" ]; then
			for line in $out; do echo "  $line"; done
		fi
	fi
}

create_user_if_not_exist() {
	if [ -n "${POSTGRES_USER}" ]; then
		userAlreadyExists=$(psql_command "SELECT 1 FROM pg_user WHERE usename='${POSTGRES_USER}';")

		if [ "${userAlreadyExists}" ] && [ "${userAlreadyExists}" -eq 1 ]; then
			echo "user ${POSTGRES_USER} already exists."
		else
			if [ -z "${POSTGRES_PWD}" ]; then
				POSTGRES_PWD=$(openssl rand -base64 33 || tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 33)
				echo "generate random password for user ${POSTGRES_USER} : ${POSTGRES_PWD}"
			fi

			userCreatedResult=$(psql_command "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PWD}';")
			if [ -z "${userCreatedResult}" ]; then
				echo "user ${POSTGRES_USER} has been created with your password."
			fi
		fi
	fi
}

create_user_and_database_if_not_exist() {
	create_user_if_not_exist

	if [ -n "${POSTGRES_DB}" ]; then
		dbAlreadyExists=$(psql_command "SELECT 1 FROM pg_database WHERE datname = '${POSTGRES_DB}';")

		if [ "${dbAlreadyExists}" ] && [ "${dbAlreadyExists}" -eq 1 ]; then
			echo "database ${POSTGRES_DB} already exists."
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

setup() {
	echo "Creating a new PostgreSQL database cluster"

	if [ -d "$data_dir/base" ]; then
		echo "$data_dir/base already exists!"; return 1
	fi

	mkdir -p "$data_dir"
	chown -R $user:$group "$data_dir"
	
	initdb_opts="-E UTF-8 --locale=C --data-checksums"
	su $user -c "/usr/bin/initdb $initdb_opts --pgdata $data_dir"
}

if [ ! -d "$data_dir/base" ]; then
    setup
fi

POSTGRES_CONFIG_PATH="$conf_dir"
POSTGRES_DATABASE_CONFIG_PATH="${POSTGRES_CONFIG_PATH}/postgresql.conf"
POSTGRES_HBA_CONFIG_PATH="${POSTGRES_CONFIG_PATH}/pg_hba.conf"

if [ -z "${POSTGRES_ROOT_PWD}" ]; then
	POSTGRES_ROOT_PWD=$(openssl rand -base64 33 || tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 33)
	echo "generate random password for user postgres : ${POSTGRES_ROOT_PWD}"
fi

if [ "${POSTGRES_DISALLOW_USER_LOGIN_REMOTELY}" -eq 0 ]; then
	sed -i "s|\#*listen_addresses\s*=\s*'localhost'|listen_addresses = '*'|g" ${POSTGRES_DATABASE_CONFIG_PATH}
fi

if [ "${POSTGRES_PORT}" -gt 0 ]; then
	sed -i "s|\#*port\s*=\s*[0-9]+|port = ${POSTGRES_PORT}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
fi

if [ -n "${POSTGRES_HOST_AUTHMETHOD}" ] && [ "${POSTGRES_HOST_AUTHMETHOD}" != "trust" ]; then
	sed -i "s|\#*password_encryption\s*=\s*scram-sha-256\|md5\|password|password_encryption = ${POSTGRES_HOST_AUTHMETHOD}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
fi

if [ "${POSTGRES_MAX_CONNECTIONS}" -gt 0 ]; then
	sed -i "s|\#*max_connections\s*=\s*[0-9]+|max_connections = ${POSTGRES_MAX_CONNECTIONS}|g" ${POSTGRES_DATABASE_CONFIG_PATH}
fi

if [ "${POSTGRES_DISALLOW_USER_LOGIN_REMOTELY}" -eq 0 ]; then
	sed -i "/^\s*host\s*all\s*all\s*0\.0\.0\.0\/0\s*${POSTGRES_HOST_AUTHMETHOD}/d" "${POSTGRES_HBA_CONFIG_PATH}"
	echo "host    all             all             0.0.0.0/0               ${POSTGRES_HOST_AUTHMETHOD}" >>"${POSTGRES_HBA_CONFIG_PATH}"
fi

echo "Starting PostgreSQL..."
su $user -c "/usr/bin/pg_ctl start -D $data_dir -l $logfile -w"

modify_root_password
create_user_and_database_if_not_exist

if [ "$DEBUG" = "true" ]; then echo "→ [postgresql] Postgresql started."; fi
