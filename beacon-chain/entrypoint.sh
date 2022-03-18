#!/bin/bash

# Concatenate EXTRA_OPTS string
[ ! -z "$CHECKPOINT_SYNC_URL" ] && EXTRA_OPTS="${EXTRA_OPTS} --initial-state=${CHECKPOINT_SYNC_URL}"

exec /opt/teku/bin/teku \
    --network=prater \
    --data-base-path=/opt/teku/data \
    --eth1-endpoint=$HTTP_WEB3PROVIDER \
    --p2p-port=9000 \
    --rest-api-cors-origins="*" \
    --rest-api-interface=0.0.0.0 \
    --rest-api-port=$BEACON_API_PORT \
    --rest-api-host-allowlist "*" \
    --rest-api-enabled=true \
    --rest-api-docs-enabled=true \
    --log-destination=CONSOLE \
    $EXTRA_OPTS
