#!/bin/sh

set -e

# Modify from https://gitlab.alpinelinux.org/alpine/aports/-/blob/master/main/postgresql-common/postgresql.initd
pg_version=$(pg_versions get-default)

name="PostgreSQL $pg_version"
description="PostgreSQL server"

extra_started_commands="stop_fast stop_force stop_smart reload reload_force promote"
description_stop_fast="Stop using Fast Shutdown mode (SIGINT)"
description_stop_force="Stop using Immediate Shutdown mode (SIGQUIT)"
description_stop_smart="Stop using Smart Shutdown mode (SIGTERM)"
description_reload="Reload configuration"
description_reload_force="Reload configuration and restart if needed"
description_promote="Promote standby server to master - exit recovery and begin read-write operations"

extra_stopped_commands="setup"
description_setup="Initialize a new $name cluster"

user="postgres"
group="postgres"

auto_setup="yes"
start_timeout=10
# nice_timeout, rude_timeout and force_timeout are for backward compatibility.
stop_smart_timeout=${nice_timeout:-5}
stop_fast_timeout=${rude_timeout:-10}
stop_force_timeout=${force_timeout:-0}

data_dir="/var/lib/postgresql/$pg_version/data"
conf_dir="/etc/postgresql"
logfile="/var/log/postgresql/postmaster.log"
env_vars=
pg_opts=
port=5432

command="/usr/libexec/postgresql$pg_version/postgres"

conffile="$conf_dir/postgresql.conf"
pidfile="$data_dir/postmaster.pid"
start_stop_daemon_args="
	--user $user
	--group $group
	--pidfile $pidfile
	--wait 100"

service_set_value() {
    local service_name=$1
    local value=$2
    echo "$service_name=$value" >> /tmp/service_values
}

service_get_value() {
    local service_name=$1
    grep "^$service_name=" /tmp/service_values | cut -d'=' -f2
}

depend() {
	use net
	after firewall

	if [ "$(get_config log_destination)" = "syslog" ]; then
		use logger
	fi
}

start_pre() {
	check_deprecated_var nice_timeout stop_smart_timeout
	check_deprecated_var rude_timeout stop_fast_timeout
	check_deprecated_var rude_quit stop_fast_timeout
	check_deprecated_var force_timeout stop_force_timeout
	check_deprecated_var force_quit stop_force_timeout
	check_deprecated_var env_vars 'export NAME=VALUE'

	# For backward compatibility only.
	[ "$rude_quit" = no ] && [ "stop_fast_timeout" -eq 10 ] && stop_fast_timeout=0
	[ "$force_quit" = yes ] && [ "$stop_force_timeout" -eq 0 ] && stop_force_timeout=2

	if [ ! -d "$data_dir/base" ]; then
		if [ "$auto_setup" = "yes" ]; then
			setup || return 1
		else
			eerror "Database not found at: $data_dir"
			eerror "Please make sure that 'data_dir' points to the right path."
			eerror "You can run '/etc/init.d/postgresql setup' to setup a new database cluster."
			return 1
		fi
	fi

	# This is mainly for backward compatibility with the former $conf_dir default value.
	if [ "$conf_dir" = /etc/postgresql ] && ! [ -f "$conf_dir/postgresql.conf" ]; then
		conf_dir=$data_dir
	fi

	local socket_dirs=$(get_config "unix_socket_directories" "/run/postgresql")
	local port=$(get_config "port" "$port")

	start_stop_daemon_args="$start_stop_daemon_args --env PGPORT=$port"

	local var; for var in $env_vars; do
		start_stop_daemon_args="$start_stop_daemon_args --env $var"
	done

	(
		# Set the proper permission for the socket paths and create them if
		# they don't exist.
		set -f; IFS=","
		for dir in $socket_dirs; do
			if [ -e "${dir%/}/.s.PGSQL.$port" ]; then
				eerror "Socket conflict. A server is already listening on:"
				eerror "    ${dir%/}/.s.PGSQL.$port"
				eerror "Hint: Change 'port' to listen on a different socket."
				return 1
			elif [ "${dir%/}" != "/tmp" ]; then
				checkpath -d -m 1775 -o $user:$group "$dir"
			fi
		done
	)
}

start() {
	ebegin "Starting $name"

	rm -f "$pidfile"
	start-stop-daemon --start \
		$start_stop_daemon_args \
		--exec /usr/bin/pg_ctl \
		-- start \
			--silent \
			-w --timeout="$start_timeout" \
			--log="$logfile" \
			--pgdata="$conf_dir" \
			-o "--data-directory=$data_dir $pg_opts"

	if eend $? "Failed to start $name"; then
		service_set_value "command" "$command"
		service_set_value "pidfile" "$pidfile"
	else
		eerror "Check the log for a possible explanation of the above error:"
		eerror "    $logfile"
		return 1
	fi
}

stop() {
	local command=$(service_get_value "command" || echo "$command")
	local pidfile=$(service_get_value "pidfile" || echo "$pidfile")
	local retry=''

	[ "$stop_smart_timeout" -eq 0 ] \
		|| retry="SIGTERM/$stop_smart_timeout"
	[ "$stop_fast_timeout" -eq 0 ] \
		|| retry="${retry:+$retry/}SIGINT/$stop_fast_timeout"
	[ "$stop_force_timeout" -eq 0 ] \
		|| retry="${retry:+$retry/}SIGQUIT/$stop_force_timeout"
	[ "$retry" ] \
		|| retry='SIGINT/5'

	local seconds=$(( $stop_smart_timeout + $stop_fast_timeout + $stop_force_timeout ))

	ebegin "Stopping $name (this can take up to $seconds seconds)"

	start-stop-daemon --stop \
		--exec "$command" \
		--retry "$retry" \
		--progress \
		--pidfile "$pidfile"
	eend $? "Failed to stop $name"
}

stop_smart() {
	_stop SIGTERM "smart shutdown"
}

stop_fast() {
	_stop SIGINT "fast shutdown"
}

stop_force() {
	_stop SIGQUIT "immediate shutdown"
}

_stop() {
	local command=$(service_get_value "command" || echo "$command")
	local pidfile=$(service_get_value "pidfile" || echo "$pidfile")

	ebegin "Stopping $name ($2)"

	start-stop-daemon --stop \
		--exec "$command" \
		--signal "$1" \
		--pidfile "$pidfile" \
		&& mark_service_stopped "$RC_SVCNAME"
	eend $? "Failed to stop $name"
}

reload() {
	ebegin "Reloading $name configuration"

	start-stop-daemon --signal HUP --pidfile "$pidfile" && check_config_errors
	local retval=$?

	is_pending_restart || true

	eend $retval
}

reload_force() {
	ebegin "Reloading $name configuration"

	start-stop-daemon --signal HUP --pidfile "$pidfile" && check_config_errors
	local retval=$?

	if [ $retval -eq 0 ] && is_pending_restart; then
		rc-service --nodeps "$RC_SVCNAME" restart
		retval=$?
	fi
	eend $retval
}

promote() {
	ebegin "Promoting $name to master"

	cd "$data_dir"  # to avoid the: could not change directory to "/root"
	su $user -c "pg_ctl promote --wait --log=$logfile --pgdata=$conf_dir -o '--data-directory=$data_dir'"
	eend $?
}

setup() {
	local bkpdir

	ebegin "Creating a new $name database cluster"

	if [ -d "$data_dir/base" ]; then
		eend 1 "$data_dir/base already exists!"; return 1
	fi

	if [ "$pg_version" -ge 15 ]; then
		: ${initdb_opts:="-E UTF-8 --locale-provider=icu --icu-locale=en-001-x-icu --data-checksums"}
	else
		: ${initdb_opts:="-E UTF-8 --locale=C --data-checksums"}
	fi

	# If data_dir exists, backup configs.
	if [ -d "$data_dir" ]; then
		bkpdir="$(mktemp -d)"
		find "$data_dir" -type f -name "*.conf" -maxdepth 1 \
			-exec mv -v {} "$bkpdir"/ \;
		rm -rf "$data_dir"/*
	fi

	install -d -m 0700 -o $user -g $group "$data_dir"
	install -d -m 0750 -o $user -g $group "$conf_dir"

	cd "$data_dir"  # to avoid the: could not change directory to "/root"
	su $user -c "/usr/bin/initdb $initdb_opts --pgdata $data_dir"
	local retval=$?

	if [ -d "$bkpdir" ]; then
		# Move backuped configs back.
		mv -v "$bkpdir"/* "$data_dir"/
		rm -rf "$bkpdir"
	fi

	local conf_dir=$(readlink -f "$conf_dir")

	if [ "${data_dir%/}" != "${conf_dir%/}" ]; then
		# Move configs from data_dir to conf_dir and symlink them to data_dir.
		local name newname
		for name in postgresql.conf pg_hba.conf pg_ident.conf; do
			newname="$name"
			[ ! -e "$conf_dir"/$name ] || newname="$name.new"

			mv "$data_dir"/$name "$conf_dir"/$newname
			ln -s "$conf_dir"/$name "$data_dir"/$name
		done
	fi

	eend $retval
} 


get_config() {
	local name="$1"
	local default="${2:-}"

	if [ ! -f "$conffile" ]; then
		printf '%s\n' "$default"
		return 1
	fi
	sed -En "/^\s*${name}\b/{                      # find line starting with the name
		  s/^\s*${name}\s*=?\s*([^#]+).*/\1/;  # capture the value
		  s/\s*$//;                            # trim trailing whitespaces
		  s/^['\"](.*)['\"]$/\1/;              # remove delimiting quotes
		  p
		}" "$conffile" \
		| grep . || printf '%s\n' "$default"
}

check_config_errors() {
	local out; out=$(psql_command "
		select
		  sourcefile || ': line ' || sourceline || ': ' || error ||
		    case when name is not null
		    then ': ' || name || ' = ''' || setting || ''''
		    else ''
		    end
		from pg_file_settings
		where error is not null
		  and name not in (select name from pg_settings where pending_restart = true);
		")
	if [ $? -eq 0 ] && [ "$out" ]; then
		eerror 'Configuration file contains errors:'
		printf '%s\n' "$out" | while read line; do
			eerror "  $line"
		done
		return 1
	fi
}

is_pending_restart() {
	local out; out=$(psql_command "select name from pg_settings where pending_restart = true;")

	if [ $? -eq 0 ] && [ "$out" ]; then
		ewarn 'PostgreSQL must be restarted to apply changes in the following parameters:'
		local line; for line in $out; do
			ewarn "  $line"
		done
		return 0
	fi
	return 1
}

check_deprecated_var() {
	local old_name="$1"
	local new_name="$2"

	if [ -n "$(getval "$old_name")" ]; then
		ewarn "Variable '$old_name' is deprecated, please use '$new_name' instead."
	fi
}

getval() {
	eval "printf '%s\n' \"\$$1\""
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
start_pre

POSTGRES_CONFIG_PATH="/etc/postgresql$pg_version"
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
start
modify_root_password
create_user_and_database_if_not_exist

# exec commands
if [ -n "$*" ]; then
	sh -c "$*"
fi

# keep the docker container running
# https://github.com/docker/compose/issues/1926#issuecomment-422351028
if [ "${KEEPALIVE}" -eq 1 ]; then
	trap stop_smart TERM INT
	tail -f /dev/null &
	wait
	# sleep infinity & wait
fi
