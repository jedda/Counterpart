Counterpart Sample Files
====================

This folder contains sample files that can be used in conjunction with Counterpart. A description of each sample file can be found below:

counterpart\_exclude.sample
--------------------
This file is an example of one that can be provided to Counterpart through it's `-e` option to exclude a set of files or file patterns. This file is simply passed through to rsync's `--exclude-from` option, and as such, the rules for providing files and patterns are the same as rsync. For more information, see the "Include/Exclude Pattern Rules" section of the [rsync man page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/rsync.1.html). The counterpart\_exclude.sample file includes some popular file and directory exclusions from bootable clones that you may wish to use for your own systems.

It is suggested that you store your list of counterpart exclusions in the file `/etc/counterpart_exclude` and therefore use it with Counterpart in this manner:
    counterpart -s / -d /Volumes/Clone -e /etc/counterpart_exclude

counterpart\_dump\_mysql.sh.sample
--------------------
This file is a _very_ simple example of a pre-clone script that can be provided to Counterpart through it's `-p` option. This example dumps MySQL databases to disk before Counterpart clones the source. Something like this can be very helpful in ensuring databases are backed up, but this exact sample should not be used in production, as it supplies the password for the MySQL database in cleartext on the command line, and is therefore quite insecure.

me.jedda.counterpart.plist.simple.sample
--------------------
This file is the first of two examples of launchd plists that can be used to schedule clones with Counterpart. For more information on scheduling Counterpart, see the [SCHEDULING](https://github.com/jedda/Counterpart/blob/master/SCHEDULING.md) file in the Counterpart repository.

This example plist schedules a clone from the root of the boot drive (/) to another mounted volume (/Volumes/Server Clone/) at 1:00AM each morning.

me.jedda.counterpart.plist.complex.sample
--------------------
This file is the second of two examples of launchd plists that can be used to schedule clones with Counterpart. For more information on scheduling Counterpart, see the [SCHEDULING](https://github.com/jedda/Counterpart/blob/master/SCHEDULING.md) file in the Counterpart repository.

This slightly more complex example again clones from the root of the boot drive (/) to another mounted volume (/Volumes/Server Clone/), but does so every 2 hours. It also reads a list of excluded files and patterns from a file at /etc/counterpart_exclusions, backs up OS X server databases using the password 'secret', and runs a pre-clone script; counterpart\_dump\_mysql.sh (also included in this sample directory).
