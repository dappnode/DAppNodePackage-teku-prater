ARG UPSTREAM_VERSION

########
# TEKU #
########
FROM consensys/teku:22.3.1

USER root 
RUN apt update && apt install cron jq supervisor --yes

# Setup cronjob
COPY get-keys-cron /etc/cron.d/
COPY get-keys.sh /usr/local/bin/get-keys.sh
# Apply cron job
RUN crontab /etc/cron.d/get-keys-cron

ENV JAVA_OPTS="-Xmx4g"

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]