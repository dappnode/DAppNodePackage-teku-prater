ARG UPSTREAM_VERSION

########
# TEKU #
########
FROM consensys/teku:$UPSTREAM_VERSION

USER root 
RUN apt update && apt install curl jq ca-certificates --yes

ENV JAVA_OPTS="-Xmx5g"

COPY /security/validator-api-bearer /opt/teku/data/validator/key-manager/validator-api-bearer 
COPY /security/cert /cert
COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
