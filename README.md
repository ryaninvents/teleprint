# teleprint

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/baconscript/teleprint?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/baconscript/teleprint.svg?branch=master)](https://travis-ci.org/baconscript/teleprint)

Node.js-based 3D print host.

Currently a work in progress. Once this is usable for basic printing, I'll mark a 1.0 release.

Released under the GPLv3 license. For more info, see [LICENSE.md](LICENSE.md).

## Installation

    git clone https://github.com/baconscript/teleprint.git
    cd teleprint
    npm install

## Notes for Linux

On Linux, you'll have to add your user to either the `dialout` or `uucp` group, depending on your
distro. Otherwise, you'll have to be `root` or use `sudo` for Teleprint to communicate with your
serial ports.

**Ubuntu/Debian:** `sudo usermod -a -G dialout <username>`

**Arch:** `sudo usermod -a -G uucp <username>`

## Running

    npm start
