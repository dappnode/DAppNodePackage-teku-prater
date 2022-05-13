#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n $CHECKPOINT_SYNC_URL ]] && EXTRA_OPTS="--initial-state=${CHECKPOINT_SYNC_URL}/eth/v2/debug/beacon/states/finalized ${EXTRA_OPTS}"

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
    --metrics-enabled=true \
    --metrics-interface 0.0.0.0 \
    --metrics-port 8008 \
    --metrics-host-allowlist "*" \
    --log-destination=CONSOLE \
    $EXTRA_OPTS
