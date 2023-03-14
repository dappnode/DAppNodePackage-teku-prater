ARG UPSTREAM_VERSION

########
# TEKU #
########
# IMPORTANT!: this docker image has a root user with password. Cannot execute apt update and apt install
FROM consensys/teku:$UPSTREAM_VERSION

# Give proper permissions to docker volume https://docs.teku.consensys.net/en/latest/HowTo/Get-Started/Installation-Options/Run-Docker-Image/#allow-multiple-users-to-run-the-docker-image
USER root
RUN apt update && apt install wget --yes
RUN mkdir -p /opt/teku/data
RUN chown -R 1001:1001 /opt/teku/data

ENV JAVA_OPTS="-Xmx5g"

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY jwtsecret.hex /jwtsecret

# API port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#rest-api-port
EXPOSE $BEACON_API_PORT
# P2P port: https://docs.teku.consensys.net/en/latest/Reference/CLI/CLI-Syntax/#p2p-port
EXPOSE $P2P_PORT

ENTRYPOINT [ "entrypoint.sh" ]
