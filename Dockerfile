FROM nimlang/nim:alpine as builder
RUN mkdir /opt/vinescore

COPY src /opt/vinescore/src
COPY nim.cfg /opt/vinescore
COPY vinescore.nimble /opt/vinescore

WORKDIR /opt/vinescore
RUN nimble build --accept

FROM alpine
COPY --from=builder /opt/vinescore/bin/vinescore /usr/bin/

CMD ["/usr/bin/vinescore"]
