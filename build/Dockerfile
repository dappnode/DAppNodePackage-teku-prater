ARG UPSTREAM_VERSION

FROM golang:1.16.15-alpine3.15 as builder
WORKDIR /app 
RUN apk update && apk add git && git clone https://github.com/dappnode/eth2-pubkeys-autocheck.git
WORKDIR /app/eth2-pubkeys-autocheck/build
RUN go build -o auto-check-remote-keys main.go

########
# TEKU #
########
# IMPORTANT!: this docker image has a root user with password. Cannot execute apt update and apt install
FROM consensys/teku:$UPSTREAM_VERSION

# Copy jq binary
COPY --from=builder /usr/bin/jq /usr/bin/jq
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjq* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libonig* /usr/lib/x86_64-linux-gnu/

ENV JAVA_OPTS="-Xmx4g"

COPY --from=builder /app/build/auto-check-remote-keys /usr/local/bin/auto-check-remote-keys
COPY entrypoint.sh /usr/bin/entrypoint.sh

# API port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#rest-api-port
EXPOSE $BEACON_API_PORT
# P2P port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#p2p-port
EXPOSE 9000

ENTRYPOINT [ "entrypoint.sh" ]