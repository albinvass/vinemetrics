# Package

version       = "0.1.0"
author        = "Albin Vass"
description   = "irc bot for Vinescore"
license       = "MIT"
srcDir        = "src"
bin           = @["vinescore-irc"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.4.2"
requires "irc"
requires "metrics"
