Scheduling Counterpart with launchd
=========================

Counterpart works very well on a schedule, ensuring that a recent clone of a system's OS is available as a boot disk. It was originally designed for use on production Mac OS X Server systems; providing a secondary boot option cloned the night before for use in the case of a drive failure or similar corruption emergency. Quite separate to other backup means, it provides a quick way to get a system back up and running almost instantly.

Below, you will find an template launchd plist that can be used to schedule Counterpart, as well as instructions on how to install and load it. There are also several example plists with descriptions that shows how to setup Counterpart to do a few different things.

* Enter the following command: `sudo nano /Library/LaunchDaemons/me.jedda.counterpart.plist`

* Copy and paste the property list below into nano, enter a valid source and destination path, and alter the execution time to your choice. You are also free to add any other arguments to the ProgramArguments array as you choose, such as an -e flag for rsync\_exclude (see the Counterpart README for options and flags).

* Once finished, use `Control-O` to write the new plist file, and `Control-X` to exit nano.

* Enter the following command: `sudo launchctl load /Library/LaunchDaemons/me.jedda.counterpart.plist`

* All done! launchd will now execute Counterpart with the provided arguments at the set calendar interval. 

Template Plist
--------------
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>Label</key>
    <string>me.jedda.counterpart</string>
    <key>ProgramArguments</key>
    <array>
    	<string>/usr/sbin/counterpart.sh</string>
		<string>-s</string>
		<string>[source]</string>
		<string>-d</string>
    	<string>[destination]</string>
    </array>
	<key>Nice</key>
	<integer>19</integer>
	<key>LowPriorityIO</key>
	<true/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>01</integer>
        <key>Minute</key>
        <integer>00</integer>
    </dict>
    </dict>
    </plist>

Sample plist Files
--------------

For some sample launchd plists showing how to configure a scheduled clone a few different ways, please see [me.jedda.counterpart.plist.simple.sample](https://github.com/jedda/Counterpart/blob/master/samples/me.jedda.counterpart.plist.simple.sample) and [me.jedda.counterpart.plist.complex.sample](https://github.com/jedda/Counterpart/blob/master/samples/me.jedda.counterpart.plist.complex.sample) in the samples directory of the Counterpart repotsitory.
