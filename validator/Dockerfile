ARG UPSTREAM_VERSION

FROM debian:bullseye-slim as certificates

WORKDIR /usr/src/app
RUN apt update && apt install -y ca-certificates
RUN PASSWORD=$(echo $(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 20)) && \
  openssl genrsa -des3 -passout pass:${PASSWORD} -out server.pass.key 2048 && \
  openssl rsa -passin pass:${PASSWORD} -in server.pass.key -out server.key && \
  rm server.pass.key && \
  openssl req -new -key server.key -out server.csr -subj "/C=DE/ST=Decentraland/L=Decentraland/O=validator.teku-prater.dappnode/OU=validator.teku-prater.dappnode/CN=validator.teku-prater.dappnode" && \
  openssl x509 -req -sha256 -days 300065 -in server.csr -signkey server.key -out server.crt

########
# TEKU #
########
FROM consensys/teku:$UPSTREAM_VERSION

USER root 
RUN apt update && apt install cron jq ca-certificates --yes

ENV JAVA_OPTS="-Xmx4g"

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY get-keys-cron /etc/cron.d/
COPY get-keys.sh /usr/local/bin/get-keys.sh

COPY --from=certificates /usr/src/app/server.key /usr/src/app/server.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates
RUN crontab /etc/cron.d/get-keys-cron

ENTRYPOINT [ "entrypoint.sh" ]