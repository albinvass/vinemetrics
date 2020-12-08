# Package

version       = "0.1.0"
author        = "Albin Vass"
description   = "Score tracker for Vinesauce"
license       = "MIT"
srcDir        = "src"
bin           = @["vinescore"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.4.2"
requires "irc"
requires "metrics"
