import os
import net
import irc
import strformat
import tables
import strutils
import logging
import system
import metrics


type
  VineScore = ref object
    channel: string
    currentScore*: int64
    gauge: Gauge
    maxVote: int
    minVote: int

proc newVineScore*(channel: string): VineScore =
  result = VineScore(
    channel: channel,
    currentScore: 0,
    maxVote: 5,
    minVote: -5,
  )
  when defined(metrics):
    result.gauge = newGauge(channel[1..^1], &"{channel[1..^1]} gauge")

proc add*(vScore: VineScore, vote: int64) =
  if vote <= vScore.maxVote and vote >= vScore.minVote:
    vScore.currentScore += vote
    when defined(metrics):
      vScore.gauge.inc(vote)

proc main() =
  var logger = newConsoleLogger(levelThreshold=lvlDebug,
                                fmtStr="$datetime - $levelname - vinescore: ")
  when defined(metrics):
    addExportBackend(
      metricProtocol = STATSD,
      netProtocol = UDP,
      address = getEnv("VINESCORE_STATSD_HOST", "localhost"),
      port = Port(parseInt(getEnv("VINESCORE_STATSD_PORT", "8125")))
    )

  var channels = getEnv("VINESCORE_CHANNELS").split(",")

  var irc = newIrc(
    address = "irc.chat.twitch.tv",
    port = 6667.Port,
    nick = "vassast",
    joinChans = @channels,
    useSsl = false,
    serverPass = getEnv("VINESCORE_OAUTH_TOKEN"),
  )
  logger.log(lvlInfo, "Starting")
  irc.connect()

  var vScores: Table[string, VineScore]
  for channel in channels:
    vScores[channel] = newVineScore(channel)
  
  while true:
    var event: IrcEvent
    if irc.poll(event):
      case event.typ:
      of EvConnected:
        logger.log(lvlInfo, "Connected")
      of EvDisconnected:
        logger.log(lvlInfo, "Disconnected")
        logger.log(lvlInfo, "Reconnecting")
        irc.reconnect()
      of EvMsg:
        if event.cmd != MPong:
          let msg = event.params[event.params.high]
          if msg == "Improperly formatted auth":
            logger.log(lvlError, msg)
            quit(1)
          logger.log(lvlDebug, msg)
          if event.origin in vScores:
            if msg.startswith("+") or msg.startswith("-"):
              try:
                let vote = parseInt(msg)
                vScores[event.origin].add(vote)
                logger.log(lvlDebug, &"{vScores[event.origin].channel}: {vScores[event.origin].currentScore}")
              except ValueError:
                discard
        else:
          logger.log(lvlDebug, $event.raw)
      else: logger.log(lvlDebug, $event.raw)


when isMainModule:
  main()
