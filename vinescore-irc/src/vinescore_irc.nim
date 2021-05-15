import os
import net
import irc
import sugar
import tables
import system
import options
import metrics
import logging
import strutils
import parseopt
import strformat

import model


proc writeHelp() =
  echo """
  vinescore-irc

  optional arguments:
  -h, --help:   Prints this command
  -c, --config: Path to config file (default: /etc/vinescore/config.yaml)
  """


proc defaultOpts(): TableRef[string, string] =
  {"config": "/etc/vinescore/config.yaml"}.newTable

proc parseOpts(): TableRef[string, string] =
  var opts = defaultOpts()
  var p = initOptParser()
  for kind, key, val in p.getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        writeHelp()
        quit(0)
      of "config", "c": opts["config"] = val
      else:
        writeHelp()
        quit(1)
    of cmdArgument:
      writeHelp()
      quit(1)
    of cmdEnd: break
  opts


proc add*(vScore: model.Channel, vote: int64): bool =
  if vote <= vScore.maxVote and vote >= vScore.minVote:
    vScore.currentScore += vote
    when defined(metrics):
      vScore.gauge.inc(vote)
    return true
  return false

proc main() =
  var logger = newConsoleLogger(levelThreshold=lvlDebug,
                                fmtStr="$datetime - $levelname - vinescore: ")
  when defined(metrics):
    let host = getEnv("VINESCORE_STATSD_HOST", "localhost")
    let port = getEnv("VINESCORE_STATSD_PORT", "8125")
    logger.log(
        lvlInfo,
        &"Configuring export backend statsd: {host}:{port}"
    )
    addExportBackend(
      metricProtocol = STATSD,
      netProtocol = UDP,
      address = host,
      port = Port(parseInt(port))
    )

  var opts = parseOpts()
  var model = init(opts["config"])
  var joinChannels = collect(newSeq):
      for c, _ in model.channels:
        &"{c}"

  var irc = newIrc(
    address = "irc.chat.twitch.tv",
    port = 6667.Port,
    nick = "vassast",
    joinChans = @joinChannels,
    useSsl = false,
    serverPass = getEnv("VINESCORE_OAUTH_TOKEN"),
  )
  logger.log(lvlInfo, "Starting")
  irc.connect()

  var vScores = model.channels
  
  while true:
    var event: IrcEvent
    if irc.poll(event):
      case event.typ:
      of EvConnected:
        logger.log(lvlInfo, "Connected")
      of EvDisconnected:
        logger.log(lvlInfo, "Disconnected")
        irc.reconnect()
        logger.log(lvlInfo, "Reconnected")
      of EvMsg:
        if event.cmd != MPong:
          let msg = event.params[event.params.high]
          if msg == "Improperly formatted auth":
            logger.log(lvlError, msg)
            quit(1)
          logger.log(lvlDebug, &"{event.origin} - {event.nick}: {msg}")
          if event.origin in vScores:
            if msg.startswith("+") or msg.startswith("-"):
              try:
                let vote = parseInt(msg)
                if vScores[event.origin].add(vote):
                  logger.log(lvlInfo, &"USER VOTED: {event.origin} - {event.nick} - {vScores[event.origin].currentScore}")
              except ValueError:
                discard

            let channel = model.channels[event.origin]
            try:
              logger.log(lvlDebug, &"Checking emotes for {event.origin}")
              for emoteName, emote in channel.emotes.get():
                if emoteName in msg:
                  var count = count(msg, emoteName)
                  logger.log(lvlDebug, &"Incrementing {emoteName} with {count}")
                  when defined(metrics):
                    emote.gauge.inc(int64(count))
                    echo emote.gauge
            except UnpackDefect:
              logger.log(lvlDebug, &"No emotes configured for {event.origin}")

        else:
          logger.log(lvlDebug, $event.raw)
      else: logger.log(lvlDebug, $event.raw)


when isMainModule:
  main()
