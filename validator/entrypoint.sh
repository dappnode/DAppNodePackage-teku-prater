#!/bin/bash

CLIENT="teku"
NETWORK="prater"
VALIDATOR_PORT=3500
WEB3SIGNER_API="http://web3signer.web3signer-${NETWORK}.dappnode:9000"

WEB3SIGNER_RESPONSE=$(curl -s -w "%{http_code}" -X GET -H "Content-Type: application/json" -H "Host: validator.${CLIENT}-${NETWORK}.dappnode" "${WEB3SIGNER_API}/eth/v1/keystores")
HTTP_CODE=${WEB3SIGNER_RESPONSE: -3}
CONTENT=$(echo "${WEB3SIGNER_RESPONSE}" | head -c-4)

if [ "${HTTP_CODE}" == "403" ] && [ "${CONTENT}" == "*Host not authorized*" ]; then
  echo "${CLIENT} is not authorized to access the Web3Signer API. Start without pubkeys"
elif [ "$HTTP_CODE" != "200" ]; then
  echo "Failed to get keystores from web3signer, HTTP code: ${HTTP_CODE}, content: ${CONTENT}"
else
  PUBLIC_KEYS_WEB3SIGNER=($(echo "${CONTENT}" | jq -r 'try .data[].validating_pubkey'))
  if [ ${#PUBLIC_KEYS_WEB3SIGNER[@]} -gt 0 ]; then
    PUBLIC_KEYS_COMMA_SEPARATED=$(echo "${PUBLIC_KEYS_WEB3SIGNER[*]}" | tr ' ' ',')
    echo "found validators in web3signer, starting vc with pubkeys: ${PUBLIC_KEYS_COMMA_SEPARATED}"
    EXTRA_OPTS="--validators-external-signer-public-keys=${PUBLIC_KEYS_COMMA_SEPARATED} ${EXTRA_OPTS}"
  fi
fi

# Teku must start with the current env due to JAVA_HOME var
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
  --validator-api-keystore-file=/cert/teku_client_keystore.p12 \
  --validator-api-keystore-password-file=/cert/teku_keystore_password.txt \
  --logging=ALL \
  ${EXTRA_OPTS}
