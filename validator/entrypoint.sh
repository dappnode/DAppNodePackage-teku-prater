#!/bin/bash

export CLIENT="teku"
export NETWORK="prater"
export VALIDATOR_PORT=3500
export WEB3SIGNER_API="http://web3signer.web3signer-${NETWORK}.dappnode:9000"
export CLIENT_API="http://validator.${CLIENT}-${NETWORK}.dappnode:${VALIDATOR_PORT}"

if [[ $LOG_TYPE == "DEBUG" ]]; then
  export LOG_LEVEL=0
elif [[ $LOG_TYPE == "INFO" ]]; then
  export LOG_LEVEL=1
elif [[ $LOG_TYPE == "WARN" ]]; then
  export LOG_LEVEL=2
elif [[ $LOG_TYPE == "ERROR" ]]; then
  export LOG_LEVEL=3
else
  export LOG_LEVEL=1
fi

WEB3SIGNER_RESPONSE=$(curl -s -w "%{http_code}" -X GET -H "Content-Type: application/json" -H "Host: validator.${CLIENT}-${NETWORK}.dappnode" "${WEB3SIGNER_API}/eth/v1/keystores")
HTTP_CODE=${WEB3SIGNER_RESPONSE: -3}
CONTENT=$(echo "${WEB3SIGNER_RESPONSE}" | head -c-4)
if [ "$HTTP_CODE" != "200" ]; then
  echo "Failed to get keystores from web3signer, HTTP code: ${HTTP_CODE}, content: ${CONTENT}"
else
  PUBLIC_KEYS_WEB3SIGNER=($(echo "${CONTENT}" | jq -r 'try .data[].validating_pubkey'))
  if [ ${#PUBLIC_KEYS_WEB3SIGNER[@]} -gt 0 ]; then
    PUBLIC_KEYS_COMMA_SEPARATED=$(echo "${PUBLIC_KEYS_WEB3SIGNER[*]}" | tr ' ' ',')
    echo "found validators in web3signer, starting vc with pubkeys: ${PUBLIC_KEYS_COMMA_SEPARATED}"
    EXTRA_OPTS="--validators-external-signer-public-keys=${PUBLIC_KEYS_COMMA_SEPARATED} ${EXTRA_OPTS}"
  fi
fi

# Loads envs into /etc/environment to be used by the cronjob
env >>/etc/environment
# start cron and disown it
cron -f &
disown

exec /opt/teku/bin/teku --log-destination=CONSOLE \
   validator-client \
  --network=auto \
  --data-base-path=/opt/teku/data \
  --beacon-node-api-endpoint="$BEACON_NODE_ADDR" \
  --validators-external-signer-url="$WEB3SIGNER_API" \
  --metrics-enabled=true \
  --metrics-interface 0.0.0.0 \
  --metrics-port 8008 \
  --metrics-host-allowlist=* \
  --validator-api-enabled=true \
  --validator-api-interface=0.0.0.0 \
  --validator-api-port="$VALIDATOR_PORT" \
  --validator-api-host-allowlist=* \
  --validators-graffiti=\"${GRAFFITI}\" \
  --validator-api-keystore-file=/usr/local/share/ca-certificates/server.crt \
  --validator-api-keystore-password-file=/usr/local/share/ca-certificates/server.key \
  --logging=ALL \
  ${EXTRA_OPTS}
