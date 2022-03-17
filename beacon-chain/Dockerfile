ARG UPSTREAM_VERSION

########
# TEKU #
########
# IMPORTANT!: this docker image has a root user with password. Cannot execute apt update and apt install
FROM consensys/teku:$UPSTREAM_VERSION

ENV JAVA_OPTS="-Xmx4g"

COPY entrypoint.sh /usr/bin/entrypoint.sh

# API port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#rest-api-port
EXPOSE $BEACON_API_PORT
# P2P port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#p2p-port
EXPOSE 9000

ENTRYPOINT [ "entrypoint.sh" ]