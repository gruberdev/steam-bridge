#!/bin/sh -e

if [ ! -f "$CONFIG_PATH" ]; then
	echo 'No config path set, exiting...'
	exit 1
fi

if [ ! -f "$REGISTRATION_PATH" ]; then
	echo 'No registration path set, exiting...'
	exit 1
fi

args="$@"

if [ ! -z "$REG_GENERATE" ]; then
	echo -e 'Flag for registration file ENABLED, creating file at ${REGISTRATION_PATH}'
	args="-r"
fi


# if no --uid is supplied, prepare files to drop privileges
if [ "$(id -u)" = 0 ]; then
	chown node:node /data

	if find *.db > /dev/null 2>&1; then
		# make sure sqlite files are writeable
		chown node:node *.db
	fi
	if find *.log.* > /dev/null 2>&1; then
		# make sure log files are writeable
		chown node:node *.log.*
	fi

	su_exec='su-exec node:node'
else
	su_exec=''
fi

# $su_exec is used in case we have to drop the privileges
exec $su_exec /usr/local/bin/node '/opt/mx-puppet-steam/build/index.js' \
     -c "$CONFIG_PATH" \
     -f "$REGISTRATION_PATH" \
     $args
