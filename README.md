Counterpart
=========================

A wrapper script for rsync 3.0+ that is capable of producing a bootable clone of a live Mac OS X system.
Features extensive error handling, automatic logging, stats generation, Open Directory and PostgreSQL backup, and a companion Nagios plugin for monitoring clone completion and statistics.

####Usage
counterpart -s [source] -d [destination] <options>

####Options
*	 -e		:	path to exclusion patterns file. this is checked and then passed to rsync as the --exclude-from option.
*	 -b		:	password for server backup. when this option is supplied with a password, Open Directory is archived (using the supplied password) and all PostgreSQL databases
				and serveradmin settings are dumped to disk before the clone occurs. this option is only supported on 10.7+ with OS X Server installed.
*	 -B		:	same as -b but will use a password stored in the system keychain.  You must run "/path/to/counterpart setpass" once prior to using this option.				
*	 -p		:	path to pre-clone script. this script will be executed before the clone occurs, and it's output will be logged.
*	 -o		:	path to post-clone script. this script will be executed after a successful clone occurs, and it's output will be logged.
*	 -g		:	a custom organisation prefix. the default is 'me.jedda', but you may wish to supply your own to be used for counterpart's output files.
*	 -t		:	perform a test run. this will cause rsync to perform a verbose dry run, with output telling you what changes WOULD have been made. useful for troubleshooting.
*	 -h		:	display help.

####Example
counterpart -s "/" -d "/Volumes/Bootable Clone" -e "/etc/counterpart\_exclude" -b thepassword

This example will clone a bootable copy of the live Mac OS X system to a disk at /Volumes/Bootable Clone, whilst excluding any file patterns defined in /etc/counterpart_exclude and
backing up OS X Server data to disk with the password "thepassword".

####Installation:
Full installation instructions are available here: [INSTALL.md](https://github.com/jedda/Counterpart/blob/master/INSTALL.md)

####Requirements:
Counterpart requires rsync 3.0.9 or later with acl and hfs-compression patches applied. The simplest way to install this on an Intel Mac running 10.6+ is to use Homebrew.

Instructions on installing Homebrew and the appropriate version of rsync are available here: [INSTALL.md](https://github.com/jedda/Counterpart/blob/master/INSTALL.md)

#### Process

In a standard clone operation, Counterpart does the following:

1. Ensures that the correct version of rsync is available.
2. Starts logging to the defined path, creating files and directories if required.
3. Checks to see if the supplied source and directory are readable and writable.
4. Builds out a list of exclusions based on the built-in array defined at the top of the script and any file provided with -e.
5. If the -b server backup option is provided, proceeds to do archive Open Directory, dump PostgreSQL databases and backup serveradmin settings where appropriate (see OS X Server Backup section below).
6. Runs any pre-clone script provided with -p.
7. Starts the rsync process.
8. When finished, handles the rsync exit code. If 0 (success), touches a file (.me.jedda.counterpart.completed) at the root of the destination.
9. If an abnormal exit code is found, runs tests and parses output to discover why. Reasons are logged and where possible, written to a file (.me.jedda.counterpart.error) at the root of the destination. Counterpart then exits with the applicable exit code.
10. If clone was fully or partially completed, stats are generated and written to a file (.me.jedda.counterpart.stats) at the root of the destination.
11. If clone was successful, runs any post-clone script provided with -o.
12. If clone was successful, Counterpart exits with exit code 0.

#### OS X Server Backup

When the `-b` option is specified and a password provided, Counterpart will backup OS X Server data before performing a clone.

It does this as unlike a lot of flat file data on OS X, the Open Directory and PostrgreSQL databases utilised by OS X server may not be in a consistent state on the disk (changes may not have yet been written) at the time that Counterpart attempts it's clone. Because of this, the cloned database data may be corrupted, and important Server and services data may not be backed up correctly.

To combat this, Counterpart does what a lot of other OS X Server backup solutions do, and ensures that these databases are dumped to disk before it begins to clone the source disk. This option is only supported on 10.7+, and Counterpart will throw an error if you attempt to use it on an earlier version of Mac OS X. When you ask Counterpart to backup OS X Server, it does the following:

1. Ensures that you are running 10.7+ and that Server.app is installed.
2. If required creates a directory to store it's backups in (by default this is /var/backups/counterpart).
3. Archives Open Directory data, storing it in a sparse bundle encrypted with the password you provided, and saves it as OpenDirectory.sparsebundle.
3. Checks to see if a standard instance of PostgreSQL is running (on 10.7, this will almost always be the case), then dumps all databases and saves them in Postgres.bz2.
4. Checks to see if an instance of PostgreSQL for Server Services is running (on 10.8, Server runs a separate Postgres instance for it's own data), then dumps all databases and saves them in PostgresServerServices.bz2.
5. Checks to see if Mavericks server is running. If so, dumps individual service databases, and saves them as PostgresDeviceManagement.bz2, PostgresCollab.bz2 and PostgresCalendarsContacts.bz2.
6. Dumps all Server service settings as ServerSettings.plist.bz2.
7. Continues with the clone, backing up the archives and database/settings dumps in the process.

When booting to a successful Counterpart clone, you may find that all services and databases behave correctly. It is suggested however that you restore Open Directory and Postgres databases to ensure their consistency. Whilst Counterpart itself does not offer functionality to do this for you, there are plenty of tutorials on the internet that should be able to help you.

#### Scheduling & Monitoring

The original intention for, and a common use for this script is to place it on an automated schedule, automatically creating a bootable clone of a live Mac OS X system every day. A companion document, "Scheduling Counterpart with launchd" is available here: [SCHEDULING.md](https://github.com/jedda/Counterpart/blob/master/SCHEDULING.md)

A companion script for monitoring the status of scheduled clones (check\_counterpart\_clone.sh) is available in the [Mac OS X Monitoring Tools](https://github.com/jedda/Counterpart/blob/master/SCHEDULING.md) project. It is capable of reporting when a clone has not occurred within a set threshold of time, or has encountered an error. It also parses the contents of the stats file generated by Counterpart, and returns it as Nagios performance data for analysis and graphing.

#### License
Counterpart is Copyright © 2014 Jedda Wignall, and is is distributed under the terms of the GNU General Public License.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>

#### Exit Codes

Exit codes from 3 through 35 mirror rsync's exit codes ([http://wpkg.org/Rsync\_exit\_codes](http://wpkg.org/Rsync_exit_codes)) and are provided if Counterpart encounters an exact rsync error, and no extra information on that exit can be discovered. If Counterpart encounters an internal issue, or can provide more detailed information of an rsync error through parsing, it will exit via one of the codes listed below:

- 65 : Source not readable. Counterpart cannot read the supplied source directory/drive.
- 66 : Destination not writable. Counterpart cannot write to the supplied destination directory/drive.
- 67 : Excludes file not readable. An excludes pattern file was supplied, but it either does not exist, or is not readable.
- 68 : Pre-clone script not executable
- 69 : Post clone script not executable
- 70 : Test run. This was a test run.
- 71 : Source became un-readable. This occurs when rsync exits with a partial transfer error, then Counterpart's check to see if the source is still readable fails. In the case of a drive clone, this is most likely a disk I/O error and/or the source drive has unmounted.
- 72 : Destination became un-writable. This occurs when rsync exits with a protocol stream error, then Counterpart's check to see if the destination is still writable fails. In the case of a drive clone, this is most likely a disk I/O error and/or the destination drive has unmounted.
- 73 : Missing user in source ACE. This error occurs when a file on the source contains an Access Control Entry for a user that no longer exists. An example of the problem and solutions are available on the Counterpart wiki.
- 85 : rsync is not at it's assumed homebrew path.
- 86 : Wrong version of rsync.
- 90 : Destination volume is set to 'Ignore ownership on this volume'. Volume will not be bootable, so counterpart wont clone.
- 93 : Counterpart's server backup option (-b/-B)  requires Mac OS X 10.7+. This option was used on an earlier OS, and is not compatible. Remove the -b/-B option, and try again.
- 94 : Could not locate the serveradmin binary. Please ensure that OS X Server is installed correctly. If you do not want to backup OS X server data, simply omit the -b/-B option.
- 95 : Could not locate the pg_dumpall binary. Please ensure that OS X Server is installed correctly. If you do not want to backup OS X server data, simply omit the -b/-B option.
- 96 : Counterpart encountered an error when dumping PostgreSQL databases as part of an OS X Server backup.

####Support, Bugs & Issues:
This script is free and open-source, and as such, support may be limited - queries can be directed to [this contact page](http://jedda.me/contact-jedda/), and i'll get back to you as soon as I can. Any issues or bugs should be registered on the project's GitHub [Issue Tracker](https://github.com/jedda/Counterpart/issues).

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/jedda/counterpart/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/053bfedbd08debcb002f8a9f8bca5740 "githalytics.com")](http://githalytics.com/jedda/Counterpart)