FROM nimlang/nim:alpine as builder
RUN mkdir /opt/vinescore-irc

COPY nim.cfg /opt/vinescore-irc/nim.cfg
COPY src /opt/vinescore-irc/src
COPY vinescore_irc.nimble /opt/vinescore-irc
COPY statsd /opt/statsd

WORKDIR /opt/vinescore-irc
RUN cd /opt/statsd && nimble develop
RUN nimble build -d:release -d:metrics --accept

FROM alpine
COPY --from=builder /opt/vinescore-irc/bin/vinescore-irc /usr/bin/

CMD ["/usr/bin/vinescore-irc"]
