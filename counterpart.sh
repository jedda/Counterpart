#!/bin/bash

#	Counterpart
#	by Jedda Wignall
#	http://jedda.me/counterpart

#	A wrapper script for rsync 3.0+ that is capable of producing a bootable clone of a live Mac OS X system.
#	Features extensive error reporting, automatic logging and stats generation.

#	v1.0 - 17 May 2013
#	Initial release.

#	This script is Copyright © 2013 Jedda Wignall, and is is distributed under the terms of the GNU General Public License.
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>

# variables
exclusions=(".Trash" ".Trashes" ".Spotlight-*/" ".DocumentRevisions-*/" "/.fseventsd" "/.hotfiles.btree" "/private/var/db/dyld/dyld_*" "/System/Library/Caches/com.apple.bootstamps/*" "/System/Library/Caches/com.apple.corestorage/*" "/System/Library/Caches/com.apple.kext.caches/*" "/Library/Caches/*" "/Volumes/*" "/dev/*" "/automount" "/Network" "/.vol/*" "/net" "/private/var/folders/*" "/private/var/vm/*" "/private/tmp/*" "/cores")
loggingDirectory="/Library/Logs/Counterpart/"
pathToRsync="/usr/local/bin/rsync" # this is the default homebrew installed path
organisationPrefix="me.jedda" # change this if you want to customise the names of stats and flag files on disk
version="1.0"

if [[ $EUID -ne 0 ]]
then
	echo "ERROR - This script must be run as root."
	exit 1
fi

# functions
function counterpart_log {
	# create our log directory if required
	if [ ! -d "$loggingDirectory" ]; then
	  mkdir $loggingDirectory
	fi
	echo  `date +"%b %d %T"`" Counterpart[$$]: $1" | tee -a $logPath
}
function counterpart_exit {
	if [ "$1" == "" ]; then
		1="-99" # rsync crashed with no exit code. have seen this trigger in some disk malfunction scenarios.
	fi
	counterpart_log "Counterpart exited with code $1."
	exit $1
}
function counterpart_error {
	echo $1 > "$dst/.$organisationPrefix.counterpart.error"
	if [ -r "$dst/.$organisationPrefix.counterpart.completed" ]; then
		rm "$dst/.$organisationPrefix.counterpart.completed"
	fi
}
function counterpart_parse_errors {
	if [ ! -r "$src" ]; then
		counterpart_log "The source disappeared/unmounted before the clone could be completed."
		counterpart_error "source ($src) disappeared/unmounted before the clone could be completed"
		counterpart_exit 71
	elif [ ! -w "$dst" ]; then
		counterpart_log "The destination disappeared/unmounted before the clone could be completed."
		counterpart_exit 72
	elif echo $results | grep -q "unpack_smb_acl: sys_acl_get_info(): Undefined error: 0 (0)"; then
		counterpart_log "rsync did not copy a file/directory with an ACE referencing an unknown user. (solution: http://jedda.me/aclfix)"
		counterpart_error "clone from $src did not complete due to a file/directory with an ACE referencing an unknown user"
		counterpart_exit 73
	fi
}
function counterpart_generate_stats {
	# write out the stats file
	echo "Clone Started: $startTimestamp" > "$dst/.$organisationPrefix.counterpart.stats"
	echo $results | grep -E -o "Number of files: ([0-9]+)" >> "$dst/.$organisationPrefix.counterpart.stats"
	echo $results | grep -E -o "Number of files transferred: ([0-9]+)" >> "$dst/.$organisationPrefix.counterpart.stats"
	echo $results | grep -E -o "Total file size: ([0-9]+) bytes" >> "$dst/.$organisationPrefix.counterpart.stats"
	echo $results | grep -E -o "Total transferred file size: ([0-9]+) bytes" >> "$dst/.$organisationPrefix.counterpart.stats"
	echo "Clone Completed: "`date +%s` >> "$dst/.$organisationPrefix.counterpart.stats"
	counterpart_log "Saved rsync stats to $dst.$organisationPrefix.counterpart.stats"
}

while getopts "s:d:p:o:e:th" optionName; do
case "$optionName" in
s) src=( "$OPTARG" );;
d) dst=( "$OPTARG" );;
p) pre=( "$OPTARG" );;
o) post=( "$OPTARG" );;
e) excludeFrom=( "$OPTARG" );;
t) testRun="true";;
h) printHelp="true";;
esac
done

# do we need to print help?
if [ "$printHelp" == "true" ] || [ "$1" == "" ] ; then
printf "Counterpart version $version (`md5 $0 | awk '{ print substr($4,0,6) }'`).\nWritten by Jedda Wignall (http://jedda.me/counterpart/)\n\n"
printf "Counterpart is a wrapper script for rsync 3.0+ that is capable of producing a bootable clone of a live Mac OS X system.\n\n"
printf "Usage:\n$0 -s [source] -d [destination] <options>\n\n"
printf "Options:\n"
printf " -e\t\tpath to exclusion patterns file. this is checked and then passed to rsync as the --exclude-from option.\n"
printf " -p\t\tpath to pre-clone script. this script will be executed before the clone occurs, and it's output will be logged.\n"
printf " -o\t\tpath to post-clone script. this script will be executed after a successful clone occurs, and it's output will be logged.\n"
printf " -t\t\tperform a test run. this will cause rsync to perform a verbose dry run, with output telling you what changes WOULD have been made. useful for troubleshooting.\n"
printf " -h\t\tdisplay help.\n\n"
printf "Requirements:\nCounterpart requires rsync 3.0.7 or later with acl and hfs-compression patches applied. The simplest way to install this on an Intel Mac running 10.6+ is to use Homebrew.\nInstructions on installing Homebrew and the appropriate version of rsync are available at http://jedda.me/counterpart/install/\n\n"
printf "Example:\n$0 -s \"/\" -d \"/Volumes/Bootable Clone\" -e \"/etc/counterpart_exclude\"\nThis example will clone a bootable copy of the live Mac OS X system to a disk at /Volumes/Bootable Clone, whilst excluding any file patterns defined in /etc/counterpart_exclude.\n\n"
printf "More Help:\nFor a detailed overview on how this script works, including more examples, a process rundown, and possible exit codes, visit the README at https://github.com/jedda/Counterpart/blob/master/README.md\n\n"
printf "License:\nThis script is Copyright © 2013 Jedda Wignall, and is is distributed under the terms of the GNU General Public License.\nThis program is free software: you can redistribute it and/or modify\nit under the terms of the GNU General Public License as published by\nthe Free Software Foundation, either version 3 of the License, or\n(at your option) any later version.\n"
printf "This program is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\nGNU General Public License for more details.\n"
printf "You should have received a copy of the GNU General Public License\nalong with this program.  If not, see <http://www.gnu.org/licenses/>\n\n"
printf ""
printf "Support & Updates:\nFor support, bug reports, answers and updates, see http://jedda.me/counterpart/\n"
exit 0
fi

# setup our start timestamp and log file
startTimestamp=`date +%s`
logPath=$loggingDirectory"Counterpart_"`date -r $startTimestamp +%y-%m-%d_%H-%M-%S`

# check that have the right version of rsync installed
if [ ! -x "$pathToRsync" ]; then
	counterpart_log "rsync does not exist (or is not executable) at $pathToRsync. Follow the instructions at http://jedda.me/counterpart/install to install the required version of rsync before running Counterpart."
	counterpart_exit 85
elif ! $pathToRsync --version | grep -q -E -o "version 3"; then
	counterpart_log "Counterpart requires rsync version 3.0.7 or higher. Follow the instructions at http://jedda.me/counterpart/install to install the required version of rsync before running Counterpart."
	counterpart_exit 86
fi

# introduce ourselves
counterpart_log "Counterpart version $version (`md5 $0 | awk '{ print substr($4,0,6) }'`)."
counterpart_log "Logging to $logPath."

# check that source is defined
if [ "$src" == "" ]; then
	counterpart_log "Source not defined. Cannot continue with the clone process."
	counterpart_exit 2
fi

# check that destination is defined
if [ "$dst" == "" ]; then
	counterpart_log "Destination not defined. Cannot continue with the clone process."
	counterpart_exit 2
fi

counterpart_log "Initialising clone from $src to $dst."

# check that the source is readable
if [ ! -r "$src" ]; then
	counterpart_log "Source ($src) is not readable. Cannot continue with the clone process."
	counterpart_error "source ($src) not readable"
    counterpart_exit 65
fi

# check that the destination is writable
if [ ! -w "$dst" ]; then
	counterpart_log "Destination ($dst) is not writable. Cannot continue with the clone process."
    counterpart_exit 66
fi

# check that the destination is not set to ignore ownership
vsdbOutput=`/usr/sbin/vsdbutil -c "$dst"`
echo $vsdbOutput
if echo $vsdbOutput | grep -q -E -o "disabled"; then
	counterpart_log "Destination ($dst) is set to 'Ignore ownership on this volume'. Volume will not be bootable! Cannot continue with the clone process."
    counterpart_exit 90
fi

# build our exclusions string
for exc in "${exclusions[@]}"
do
  excludeString="$excludeString--exclude=$exc "
done
if [ "$excludeFrom" != "" ]; then
	# make sure that we can read the excludes file
	if [ -r "$excludeFrom" ]; then
		excludeString="$excludeString--exclude-from=$excludeFrom "
	else
		counterpart_log "Could not read supplied excludes file ($excludeFrom). Cannot continue with the clone process."
		counterpart_error "rsync could not read supplied exclude-from file ($excludeFrom)"
		counterpart_exit 67
	fi
fi

# check to see if this is a test run
if [ "$testRun" == "true" ]; then
	counterpart_log "Test option specified. Performing a test run - will log all output below:"
	$pathToRsync -n --acls --archive --delete --delete-excluded $excludeString --hard-links --hfs-compression --one-file-system --protect-decmpfs --sparse --verbose --xattrs "$src" "$dst" 2>&1 | tee -a $logPath
	counterpart_exit 70
fi

# check to see if we need to execute a pre-clone script
if [ "$pre" != "" ]; then
	if [ ! -x "$pre" ]; then
		counterpart_log "The pre-clone script at $pre does not exist or could not be executed."
		counterpart_exit 68
	fi
	counterpart_log "Running pre-clone command '$pre'..."
	preScriptResults=`$pre`
	preScriptExitCode=$?
	counterpart_log "Pre-clone command results: `echo $preScriptResults | tr '\n' ' '` (exit code $preScriptExitCode)"
fi

# time to spin up rsync
counterpart_log "Running rsync clone..."
results=`$pathToRsync --acls --archive --delete --delete-excluded $excludeString --hard-links --hfs-compression --one-file-system --protect-decmpfs --sparse --stats --xattrs "$src" "$dst" 2>&1`
rsyncExitCode=$?

# handle the rsync exit code
case "$rsyncExitCode" in
	0)      counterpart_log "rsync completed successfully!"
			counterpart_log "rsync results: `echo $results | tr '\n' ' '`"
			touch "$dst/.$organisationPrefix.counterpart.completed"
			counterpart_generate_stats
			;;
	11)     counterpart_log "rsync file i/o error!"
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "rsync encountered a file i/o error whilst cloning from $src"
			counterpart_generate_stats
			counterpart_exit 11
			;;
	12)     counterpart_log "rsync protocol data stream error!"
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "rsync encountered a data stream error whilst cloning from $src"
			counterpart_generate_stats
			counterpart_parse_errors
			counterpart_exit 12
			;;
	24)    	counterpart_log "rsync source files vanished error!"
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "some source files vanished whilst cloning from $src"
			counterpart_generate_stats
			counterpart_exit 24
			;;
	30)     counterpart_log "rsync read/write timeout error!"
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "rsync encountered a send/recieve (read/write) timeout whilst cloning from $src"
			counterpart_generate_stats
			counterpart_parse_errors
			counterpart_exit 30
			;;
	23)     counterpart_log "rsync partial transfer error!"
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "rsync only partially completed the clone from $src due to an error"
			counterpart_generate_stats
			counterpart_parse_errors
			counterpart_exit 23
			;;
	*)		counterpart_log "rsync exited abnormally with code $rsyncExitCode."
			counterpart_log "rsync errors: `echo $results | tr '\n' ' '`"
			counterpart_error "rsync exited with abnormal code $rsyncExitCode whilst cloning from $src"
			counterpart_parse_errors
			counterpart_exit $rsyncExitCode
			;;
esac

# check to see if we need to execute a post-clone script
if [ "$post" != "" ]; then
	if [ ! -x "$post" ]; then
		counterpart_log "The post-clone script at $post does not exist or could not be executed."
		counterpart_exit 69
	fi
	counterpart_log "Running post-clone script '$post'..."
	postScriptResults=`$post`
	postScriptExitCode=$?
	counterpart_log "Post-clone command results: `echo $postScriptResults | tr '\n' ' '` (exit code $postScriptExitCode)"
fi

# exit happily
counterpart_exit 0
