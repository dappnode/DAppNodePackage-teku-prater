ARG UPSTREAM_VERSION

###########
# BUILDER #
###########
# Get jq binaries (curl is already in the consensys image)
FROM debian:bullseye-slim as builder
RUN apt update && apt install cron jq --yes

########
# TEKU #
########
# IMPORTANT!: this docker image has a root user with password. Cannot execute apt update and apt install
FROM consensys/teku:$UPSTREAM_VERSION

# Copy jq binary
COPY --from=builder /usr/bin/jq /usr/bin/jq
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjq* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libonig* /usr/lib/x86_64-linux-gnu/
# Copy crontab and cron binary
COPY --from=builder /usr/sbin/cron /usr/sbin/cron
COPY --from=builder /usr/bin/crontab /usr/bin/crontab
COPY --from=builder /var/spool/cron /var/spool/cron

# Setup cronjob
COPY get-keys-cron /etc/cron.d/
COPY get-keys.sh /usr/local/bin/get-keys.sh
# Apply cron job
RUN crontab /etc/cron.d/get-keys-cron


ENV JAVA_OPTS="-Xmx4g"

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]