#!/bin/bash

# Concatenate EXTRA_OPTS string
[[ -n $CHECKPOINT_SYNC_URL ]] && EXTRA_OPTS="--initial-state=${CHECKPOINT_SYNC_URL}/eth/v2/debug/beacon/states/finalized ${EXTRA_OPTS}"

case $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER in
"goerli-geth.dnp.dappnode.eth")
    HTTP_ENGINE="http://goerli-geth.dappnode:8551"
    ;;
"goerli-nethermind.dnp.dappnode.eth")
    HTTP_ENGINE="http://goerli-nethermind.dappnode:8551"
    ;;
"besu-goerli.dnp.dappnode.eth")
    HTTP_ENGINE="http://besu-goerli.dappnode:8551"
    ;;
"goerli-erigon.dnp.dappnode.eth")
    HTTP_ENGINE="http://goerli-erigon.dappnode:8551"
    ;;
*)
    echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER: $_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER"
    HTTP_ENGINE=$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_PRATER
    ;;
esac

# MEVBOOST: https://docs.teku.consensys.net/en/latest/HowTo/Builder-Network/
if [ -n "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" ] && [ "$_DAPPNODE_GLOBAL_MEVBOOST_PRATER" == "true" ]; then
    echo "MEVBOOST is enabled"
    MEVBOOST_URL="http://mev-boost.mev-boost-goerli.dappnode:18550"
    if curl --retry 5 --retry-delay 5 --retry-all-errors "${MEVBOOST_URL}"; then
        EXTRA_OPTS="--builder-endpoint=${MEVBOOST_URL} ${EXTRA_OPTS}"
    else
        echo "MEVBOOST is enabled but ${MEVBOOST_URL} is not reachable"
        curl -X POST -G 'http://my.dappnode/notification-send' --data-urlencode 'type=danger' --data-urlencode title="${MEVBOOST_URL} is not available" --data-urlencode 'body=Make sure the mevboost is available and running'
    fi
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
