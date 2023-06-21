Freespoke for iOS
===============

Download on the [App Store](https://itunes.apple.com/app/id1617332602).


This branch (main)
-----------

This branch works with [Xcode 14.2.0](https://developer.apple.com/download/all/?q=xcode), Swift 5.7 and supports iOS 13 and above.

*Please note:* Both Intel and M1 macs are supported 🎉 and we use swift package manager.

Building the code
-----------------

1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
1. Install, [Brew](https://brew.sh), Node, and a Python3 virtualenv for localization scripts:
    ```shell
    brew update
    brew install node
    pip3 install virtualenv
    ```
1. Clone the repository:
    ```shell
    git clone https://github.com/Freespoke/freespoke-browser-ios
    ```
1. Install Node.js dependencies, build user scripts and update content blocker:
    ```shell
    cd freespoke-browser-ios
    sh ./bootstrap.sh
    ```
1. Open `Client.xcodeproj` in Xcode.
1. Build the `Fennec` scheme in Xcode.

Note: In case you have dependencies issues with SPM, you can try:
- Xcode -> File -> Packages -> Reset Package Caches
- Xcode -> File -> Packages -> Resolve Package Versions

Firefox for iOS
-----------------

    https://github.com/mozilla-mobile/firefox-ios

License
-----------------

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at https://mozilla.org/MPL/2.0/
   

    
