Installing Counterpart Pre-requisites
=========================

Counterpart requires a newer version of rsync than currently ships with Mac OS X. Currently, the minimum supported version is rsync 3.0.7 or later with acl and hfs-compression patches applied.

Luckily, the required binary with patches is easily installed with Homebrew, an excellent package manager for OS X.

*Unfortunately, the current version of rsync (3.1.0) has a bug when built on Mac OS X that causes issues with counterpart. Because of this, the instructions below have been altered slightly to build and install a specific version of rsync (3.0.9). Once the bug in the 3.1 branch is corrected, the instructions will be updated to build and install the latest version.*

The instructions below detail how to install Homebrew and the required version of rsync. If you already have Homebrew installed, simply skip to step *.

1. Download and install [Xcode](http://itunes.apple.com/us/app/xcode/id497799835) or [Command Line Tools for Xcode](https://developer.apple.com/downloads). More info available here: [https://github.com/mxcl/homebrew/wiki/Installation](https://github.com/mxcl/homebrew/wiki/Installation).
2. Visit the [Homebrew site](http://brew.sh/), and scroll down to the Install Homebrew heading. As instructed, paste the ruby command listed into a Terminal prompt.
3. At a Terminal prompt, run `brew doctor` to ensure Homebrew is installed.
4. Next, tap the dupes by `brew tap homebrew/dupes` so libiconv will work correctly.
4. At a Terminal prompt, run `brew install https://github.com/Homebrew/homebrew-dupes/blob/109dca908c6499116e07483d7afe8a1c3ef63ad6/rsync.rb` to install version 3.0.9 of rsync from the homebrew-dupes repository.
4. At a Terminal prompt, run `/usr/local/bin/rsync --version`, and verify that it displays version 3.0.7 or later.

You should now be able to run Counterpart on your Mac. You can place counterpart.sh wherever you fancy, but if you want it in your path, it is suggested that it live at /usr/sbin.
