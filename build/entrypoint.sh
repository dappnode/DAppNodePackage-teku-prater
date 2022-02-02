#!/bin/bash
#
# 1. Fetches the public keys from the web3signer API
# 2. Checks if the public keys are valid
# 3. CUSTOM: create string with public keys comma separated
# 4. Starts the validator
# IMPORTANT! the teku binary executes at the same time validator and beaconchain. The binary that starts the 
# beaconchain must be executed in any case.

ERROR="[ ERROR ]"
INFO="[ INFO ]"

WEB3SIGNER_AVAILABLE=true

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
    --retry 2 \
    --retry-delay 2 \
    --retry-max-time 40 \
    "${HTTP_WEB3SIGNER}/eth/v1/keystores"); then
        if PUBLIC_KEYS_PARSED=$(echo ${PUBLIC_KEYS} | jq -r '.data[].validating_pubkey' | tr ' ' ','); then
            # convert array of strings to string comma separated to be used by the teku binary
            echo "${INFO} found public keys: $PUBLIC_KEYS_PARSED"
        else
            { echo "${ERROR} something wrong happened parsing the public keys"; exit 1; }
        fi
    else
        echo "${WARN} web3signer not available"
        WEB3SIGNER_AVAILABLE=false
    fi
}

# Writes public keys to file by new line separated
# creates file if it does not exist
function write_public_keys() {
    rm -rf ${PUBLIC_KEYS_FILE}
    echo "${INFO} writing public keys to file"
    for key in ${PUBLIC_KEYS_PARSED}; do
        echo "${key}" >> ${PUBLIC_KEYS_FILE}
    done
}

########
# MAIN #
########

# Get public keys from API keymanager
get_public_keys

# Check public keys is not empty
[ -z "${PUBLIC_KEYS_PARSED}" ] && { echo "${ERROR} no public keys found in API keymanager endpoint /eth/v1/keystores"; exit 1; }

# Write public keys to file
write_public_keys

echo "${INFO} starting cronjob"
cron

if [ "${WEB3SIGNER_AVAILABLE}" = true ]; then
    echo "${INFO} starting teku with validator and beaconchain"
else
    echo "${WARN} web3signer not available"
    echo "${WARN} starting teku with validator only"
fi

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
