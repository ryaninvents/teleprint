# teleprint

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/baconscript/teleprint?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://img.shields.io/travis/baconscript/teleprint.svg?style=flat)](https://travis-ci.org/baconscript/teleprint)
[![Build Status](https://img.shields.io/travis/baconscript/teleprint/develop.svg?label=develop branch&style=flat)](https://travis-ci.org/baconscript/teleprint)

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

You can run `npm start` to get up and running quickly.

If you'd like to use the simulated printer, run

    bin/teleprint --sim

For more options, run `bin/teleprint --help`.

    $  bin/teleprint --help

    Usage: node teleprint [options]

    Options:
    -p, --port      Select which port to run on
    -a, --address   Set the address to listen on (default is localhost)
    --any-address   Respond to requests to any address (insecure)
    -s, --sim       Enable simulated printers
