#!/usr/bin/env bash

if [[ $# -eq 0 ]]; then
	# shellcheck disable=SC1091
	. /etc/sysconfig/httpd
	exec /usr/sbin/apachectl -D FOREGROUND
fi

exec /usr/bin/env "$@"
