#!/bin/sh

### BEGIN INIT INFO
# Provides:          cocained
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Cocaine Server
# Description:       ZeroMQ-based modular asynchronous application server.
#                    Install some language-support modules if you want it to actually start.
### END INIT INFO

# Author: Andrey Sibiryov <kobolog@yandex-team.ru>

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DESC="the omnipotent"
NAME=cocaine
DAEMON=/usr/bin/cocained
DAEMON_ARGS="--daemonize"
SCRIPTNAME=/etc/init.d/cocaine-core

# Exit if the package is not installed
[ -x $DAEMON ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME-core ] && . /etc/default/$NAME-core

PIDFILE=/var/run/cocaine/cocaine.pid

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

if [ ! -d /var/run/cocaine ]; then
    mkdir -p /var/run/cocaine
    chown cocaine:adm /var/run/cocaine
fi

if [ ! -d /var/run/cocaine ]; then
    mkdir -p /var/run/cocaine
    chown cocaine:adm /var/run/cocaine
fi

#
# Function that starts the daemon/service
#
do_start() {
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null \
		|| return 1
	start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --chuid cocaine -- \
		$ENDPOINT $DAEMON_ARGS --storage:driver $STORAGE_DRIVER --storage:uri $STORAGE_URI \
        --pidfile $PIDFILE \
		|| return 2
}

#
# Function that stops the daemon/service
#
do_stop() {
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name cocained
	return $?
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name cocained
	return 0
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC " "$NAME"
    do_start
    case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
  ;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  reload|force-reload)
	log_daemon_msg "Reloading $DESC" "$NAME"
	do_reload
	log_end_msg $?
	;;
  restart)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	  0|1)
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	  *)
	  	# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

:
