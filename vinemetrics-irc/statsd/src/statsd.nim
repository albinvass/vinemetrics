import net
import strutils
import strformat

type
  Statsd* = ref object
    hostname: string
    port: Port
    socket: Socket

  Gauge* = ref object
    name: string
    statsd: Statsd

proc newStatsd*(hostname = "localhost", port = 8125): Statsd =
  Statsd(
    hostname: hostname,
    port: Port(port),
    socket: newSocket(
      AF_INET,
      SOCK_DGRAM,
      IPPROTO_UDP,
      buffered = false
    )
  )

template send(statsd: Statsd, msg: string) =
  statsd.socket.sendTo(
    statsd.hostname,
    statsd.port,
    msg
  )

proc newGauge*(statsd: Statsd, name: string): Gauge =
  Gauge(
    name: name,
    statsd: statsd,
  )

proc inc*(gauge: Gauge, val: int|float) =
  gauge.statsd.send(&"{gauge.name}:+{val}|g\n")
