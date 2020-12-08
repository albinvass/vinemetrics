FROM nimlang/nim:alpine as builder
RUN mkdir /opt/vinescore-api

COPY src /opt/vinescore-api/src
COPY vinescore_api.nimble /opt/vinescore-api

WORKDIR /opt/vinescore-api
RUN nimble build --accept

FROM alpine
COPY --from=builder /opt/vinescore-api/bin/vinescore-api /usr/bin/

CMD ["/usr/bin/vinescore-api"]
