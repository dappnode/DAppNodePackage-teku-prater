#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n $CHECKPOINT_SYNC_URL ]] && EXTRA_OPTS="--initial-state=${CHECKPOINT_SYNC_URL}/eth/v2/debug/beacon/states/finalized ${EXTRA_OPTS}"

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER in
"goerli-geth.dnp.dappnode.eth")
    HTTP_ENGINE="http://goerli-geth.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER"
    HTTP_ENGINE=_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER
    ;;
esac

# MEVBOOST: https://docs.teku.consensys.net/en/latest/HowTo/Builder-Network/
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" == "true" ]; then
    echo "MEVBOOST is enabled"
    EXTRA_OPTS="--builder-endpoint=http://mev-boost-goerli.mev-boost.dappnode:18550 ${EXTRA_OPTS}"
fi

exec /opt/teku/bin/teku \
    --network=prater \
    --data-base-path=/opt/teku/data \
    --ee-endpoint=$HTTP_ENGINE \
    --ee-jwt-secret-file="/jwtsecret" \
    --p2p-port=$P2P_PORT \
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
