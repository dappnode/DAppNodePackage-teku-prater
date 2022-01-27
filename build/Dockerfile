ARG UPSTREAM_VERSION

###########
# BUILDER #
###########
# Get jq binaries (curl is already in the consensys image)
FROM debian:bullseye-slim as builder
RUN apt update && apt install -y jq

########
# TEKU #
########
# IMPORTANT!: this docker image has a root user with password. Cannot execute apt update and apt install
FROM consensys/teku:$UPSTREAM_VERSION

COPY --from=builder /usr/bin/jq /usr/bin/jq
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjq* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libonig* /usr/lib/x86_64-linux-gnu/

ENV JAVA_OPTS="-Xmx4g"

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]