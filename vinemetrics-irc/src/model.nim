import os
import irc
import tables
import logging
import statsd
import strutils
import strformat
import yaml/serialization, yaml/annotations, streams

from os import fileExists

type
  VineScoreConfig = ref object
    logger {.transient.}: ConsoleLogger
    channels*: TableRef[string, Channel]
    statsd {.transient.}: Statsd

  Channel* = ref object
    currentScore* {.transient.}: int64
    gauge* {.transient.}: Gauge
    logger {.transient.}: ConsoleLogger
    maxVote* {.defaultVal: 5.}: int
    minVote* {.defaultVal: -5.}: int
    emotes* {.sparse.}: Option[TableRef[string, ChannelEmote]]

  ChannelEmote* = ref object
    gauge* {.transient.}: Gauge

proc addScore(vScore: Channel, vote: int): bool =
  if vote <= vScore.maxVote and vote >= vScore.minVote:
    vScore.currentScore += vote
    vScore.gauge.inc(vote)
    return true
  return false

proc handleIrcEvent*(channel: var Channel, event: var IrcEvent) =
  let msg = event.params[event.params.high]
  if msg.startswith("+") or msg.startswith("-"):
    try:
      let vote = parseInt(msg)
      if channel.addScore(vote):
        channel.logger.log(lvlInfo, &"USER VOTED: {event.origin} - {event.nick} - {channel.currentScore}")
    except ValueError:
      channel.logger.log(lvlError, getCurrentExceptionMsg())

  try:
    channel.logger.log(lvlDebug, &"Checking emotes for {event.origin}")
    for emoteName, emote in channel.emotes.get():
      if emoteName in msg:
        var count = count(msg, emoteName)
        channel.logger.log(lvlDebug, &"Incrementing {emoteName} with {count}")
        emote.gauge.inc(count)
  except UnpackDefect:
    channel.logger.log(lvlDebug, &"No emotes configured for {event.origin}")

proc addLogging(config: var VineScoreConfig) =
  config.logger = newConsoleLogger(
    levelThreshold=lvlDebug,
    fmtStr="$datetime - $levelname - vinescore.model.VineScoreConfig: "
  )
  for name, channel in config.channels:
    channel.logger = newConsoleLogger(
      levelThreshold=lvlDebug,
      fmtStr= &"$datetime - $levelname - vinescore.model.channel.{name}: "
    )

proc addMetrics(config: var VineScoreConfig) =
  let host = getEnv("VINESCORE_STATSD_HOST", "localhost")
  let port = getEnv("VINESCORE_STATSD_PORT", "8125")
  config.logger.log(
      lvlInfo,
      &"Configuring statsd: {host}:{port}"
  )
  config.statsd = newStatsd(
    host,
    parseInt(port),
  )
  for channelName, channel in config.channels:
    let channelScoreGaugeName = &"{channelName[1..^1]}:score"
    channel.gauge = config.statsd.newGauge(channelScoreGaugeName)
    config.logger.log(
      lvlInfo,
      &"Configured channel gauge {channelName}"
    )
    try:
      config.logger.log(
        lvlInfo,
        &"Configuring emote gauges channel {channelName}"
      )
      for emoteName, emote in channel.emotes.get():
        let emoteGaugeName = &"{channelName[1..^1]}:emotes:{emoteName}"
        config.logger.log(
          lvlDebug,
          &"Configuring emote gauge {emoteGaugeName}" &
          &"for channel {channelName}"
        )
        emote.gauge = config.statsd.newGauge(&"{emoteGaugeName}")
    except UnpackDefect:
      config.logger.log(
        lvlDebug,
        &"No emotes configured for channel {channelName}"
      )
    
proc init*(path: string = "/etc/vinescore/config.yaml"): VineScoreConfig =
  var config: VineScoreConfig
  if fileExists(path):
    var s = newFileStream(path)
    serialization.load(s, config)
    s.close()
    addLogging(config)
    addMetrics(config)
  else:
    config = VineScoreConfig(
      channels: newTable[string, Channel]()
    )
  config
