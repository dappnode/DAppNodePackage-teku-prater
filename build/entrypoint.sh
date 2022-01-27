#!/bin/bash

# This script does the following:
# 1. Fetches the public keys from the web3signer API
# 2. Checks if the public keys are valid
# 3. CUSTOM: create string with public keys comma separated
# 4. Starts the validator

HTTP_WEB3SIGNER="http://localhost:9003"

ERROR="[ ERROR ]"
INFO="[ INFO ]"

# Get public keys from API keymanager: bash array of strings
# - Endpoint: http://web3signer.web3signer-prater.dappnode:9000/eth/v1/keystores
# - Returns:
# { "data": [{
#     "validating_pubkey": "0x93247f2209abcacf57b75a51dafae777f9dd38bc7053d1af526f220a7489a6d3a2753e5f3e8b1cfe39b56f43611df74a",
#     "derivation_path": "m/12381/3600/0/0/0",
#     "readonly": true
#     }]
# }
function get_public_keys() {
    if PUBLIC_KEYS=$(curl -s -X GET \
    -H "Content-Type: application/json" \
    --max-time 10 \
    --retry 5 \
    --retry-delay 2 \
    --retry-max-time 40 \
    "${HTTP_WEB3SIGNER}/eth/v1/keystores"); then
        if PUBLIC_KEYS_PARSED=$(echo ${PUBLIC_KEYS} | jq -r '.data[].validating_pubkey' | tr ' ' ','); then
            echo "${INFO} found public keys: $PUBLIC_KEYS_PARSED"
        else
            { echo "${ERROR} something wrong happened parsing the public keys"; exit 1; }
        fi
    else
        { echo "${ERROR} web3signer not available"; exit 1; }
    fi
}

########
# MAIN #
########

# Get public keys from API keymanager
get_public_keys

# Check public keys is not empty
[ -z "${PUBLIC_KEYS_PARSED}" ] && { echo "${ERROR} no public keys found in API keymanager endpoint /eth/v1/keystores"; exit 1; }

echo "${INFO} starting teku"
exec /opt/teku/bin/teku \
  --network=prater \
  --data-base-path=/opt/teku/data \
  --eth1-endpoint=$HTTP_WEB3PROVIDER \
  --validators-external-signer-url=$HTTP_WEB3SIGNER \
  --validators-external-signer-public-keys=$PUBLIC_KEYS_PARSED \
  --p2p-port=9000 \
  --rest-api-enabled=true \
  --rest-api-docs-enabled=true \
  --initial-state=$INITIAL_STATE \
  --log-destination=CONSOLE \
  --validators-graffiti=\"$GRAFFITI\" \
  $EXTRA_OPTS
