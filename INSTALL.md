Installing Counterpart
=========================

Counterpart requires a newer version of rsync than currently ships with Mac OS X. Currently, the minimum supported version is rsync 3.0.7 or later with acl and hfs-compression patches applied. Luckily, the required rsync binary with patches is easily installed with Homebrew, an excellent package manager for OS X. I also supply a Homebrew formula for installing Counterpart, including the required version of rsync.

NOTE: As of version 1.2, Counterpart depends on and installs rsync 3.0.9. As of this being written, rsync version 3.1.0 is broken on Mac OS X, and is unusable as a basis for Counterpart. 3.0.9 performs perfectly, and as such, is utilised by Counterpart. More information on the issues with rsync version 3.1.0 can be found [here](https://github.com/Homebrew/homebrew-dupes/issues/254).

The instructions below detail how to install Homebrew, Counterpart, and the required version of rsync. If you already have Homebrew installed, simply skip to step 4.

1. Download and install [Xcode](http://itunes.apple.com/us/app/xcode/id497799835) or [Command Line Tools for Xcode](https://developer.apple.com/downloads). More info available here: [https://github.com/mxcl/homebrew/wiki/Installation](https://github.com/mxcl/homebrew/wiki/Installation).
2. Visit the [Homebrew site](http://brew.sh/), and scroll down to the "Install Homebrew" heading. As instructed, paste the ruby command listed into a Terminal prompt, and follow the prompts.
3. At a Terminal prompt, run `brew doctor` to ensure Homebrew is installed correctly.
4. At a Terminal prompt, run `brew tap homebrew/dupes` to add the repository rsync is stored in.
5. At a Terminal prompt, run `brew tap jedda/counterpart` to add the counterpart repository itself.
6. At a Terminal prompt, run `brew install counterpart`. This will install the latest version of Counterpart, including the requisite rsync version.
7. You are ready to run Counterpart. For help, check out the README, or run `counterpart -h`.