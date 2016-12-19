#!/bin/bash
# --------------------------------------------------------------------------------
# Script name  : bash_funcs.sh
# Author       : Dave Rix (dave@analysisbydesign.co.uk)
# Created      : 2015-01-01
# Description  : Some useful bash functions
# History      :
#  2015-01-01  : DAR - Initial script
# --------------------------------------------------------------------------------

################################################################################
# Set up any functions that might be required in our scripts
################################################################################
scriptName=`basename $0 2>/dev/null`
scriptPath=`basedir $0 2>/dev/null`
[ "" = "${verbose}" ] && verbose="N"

userIP=`echo ${SSH_CLIENT} | awk '{print $1}'`
theDate=`date +"%Y%m%d"`
theTime=`date +"%H%M%S"`
dateTime=`date +"%Y-%m-%d,%H:%M:%S"`
theDTS=`date +"%Y-%m-%d-%H-%M-%S"`
startTimeime=`date +"%s"`

################################################################################
# Enable logging to /var/log/${scriptName}/${theDate}.log if we are running as
# a scheduled cron task
if [ ! -t 1 ]
then
    if [ ${logfile} = "" ]; then
        mkdir -p /var/log/${scriptName}
        logfile="/var/log/${scriptName}/${theDate}.log"
    fi
    # Close STDOUT & STDERR FD
    exec 1<&-; exec 2<&-
    # Redirect STDOUT & STDERR to logfile
    exec 1>>${logfile}; exec 2>>${logfile}
fi

################################################################################
# obtainLock - Obtains a lock file based on the calling program name...
function obtainLock () {

    # Allow for a lockfile override if provided
	[ "" = "${lockfile}" ] && lockfile="/tmp/${scriptName}.lock"

	verbose "Locking with ${lockfile}"

	if [ -f /usr/bin/lockfile ]
	then
		# We can use the procmail lockfile script :)

		# Have we been passed in a lock timeout value
		[ "" != "$1" ] && locktimeout="-l $1"

		# Attempt to create the lock file
		/usr/bin/lockfile -8 -r 5 ${locktimeout} ${lockfile}
		lockStatus=$?

	else
		# We have to resort to an old method

		# Attempt to create the lock file
		touch ${lockfile} 2>/dev/null
		lockStatus=$?

	fi

	if [ ${lockStatus} -ne 0 ]
	then
		message "Obtaining lockfile ${lockfile} failed... - already running?"
		exit -1
	fi

}

################################################################################
# removeLock - Obtains a lock file based on the calling program name...
function removeLock () {
	[ -f "${lockfile}" ] && /bin/rm -f "${lockfile}" > /dev/null 2>&1
}

################################################################################
# The exit_script function will be used to catch unwanted exits of the script
# and to perform any cleanups or email output
function exitEarly() {
    message "Exiting ${scriptDesc} due to early termination..."
    cleanup 1
}

################################################################################
# This is the cleanup function, do remove temp files and others
function cleanup() {
    ret=$1
    verbose "Running cleanup function for ${scriptDesc}"
    endTime=`microtime`
    removeTemp 2>/dev/null
    duration=`getDuration $startTime $endTime`
    verbose "Exiting ${scriptDesc} - duration ${duration} seconds."
    removeLock
    exit $ret
}

################################################################################
# message - Displays the input parameter with a date/time stamp prefix
function message () {
	thedate=`date +"%d-%b-%Y %H:%M:%S"`
	# This is a normal message statement - always show
	echo "${thedate},$1"

	msgType=$2
	[ "${msgType}" = "" ] && msgType="bash/${scriptName}"

	logger -p "user.notice" -t "${msgType}" "$1"
}

################################################################################
# verbose - Displays the input parameter with a date/time stamp prefix
#			       if the relevant variable is set
function verbose () {
	if [ "Y" = "${verbose}" -o "Y" = "${v_verbose}" ]
	then
		# This is a 'verbose' debug statement
		msgType=$2
		[ "${msgType}" = "" ] && msgType="bash/${scriptName}/verbose"
		message "$1" ${msgType}
	fi
}


################################################################################
# vverbose - Displays the input parameter with a date/time stamp prefix
#			       if the relevant variable is set
function vverbose () {
	if [ "Y" = "${v_verbose}" ]
	then
		# This is a 'very verbose' debug statement
		# Print only if v_verbose is set
		msgType=$2
		[ "${msgType}" = "" ] && msgType="bash/${scriptName}/v_verbose"
		message $1 ${msgType}
	fi
}


################################################################################
# microtime - returns a highly accurate time-stamp for monitoring purposes
function microtime() {
	date +"%s.%N"
}


################################################################################
# getDuration - returns the difference between two times
function getDuration() {
	startTime=$1
	endTime=$2

	# Check what we have received
	# and if we have no start time - cannot calc duration
	if [ "${startTime}" = "" ]
	then
		echo "n/a"
		return
	fi

	# If we have no end time - use current time
	if [ "${endTime}" = "" ]
	then
		endTime=`microtime`
	fi

	# Now do some calculation and return the duration
	echo $(( endTime - startTime + 0 ))

}


################################################################################
# dec2ip - takes a decimal number and turns it into an IP address
function dec2ip() {
	theDec=$1
	theIP=`gawk 'BEGIN {
	    dec = ARGV[1]
	    for (e = 3; e >= 0; e--) {
		octet = int(dec / (256 ^ e))
		dec -= octet * 256 ^ e
		ip = ip delim octet
		delim = "."
	    }
	    printf("%s\n", ip)
	}' ${theDec}`
	echo ${theIP}
}

################################################################################
# ip2dec - takes a decimal number and turns it into an IP address
function ip2dec() {
	theIP=$1
	theDec=`gawk 'BEGIN {
	    ip = ARGV[1]
	    split(ip, octets, ".")
	    for (i = 1; i <= 4; i++) {
		dec += octets[i] * 256 ** (4 - i)
	    }
	    printf("%i\n", dec)
	}' ${theIP}`
	echo ${theDec}
}


