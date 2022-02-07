#!/bin/bash
#
# 1. Fetches the public keys from the web3signer API
# 2. Checks if the public keys are valid
# 3. CUSTOM: create string with public keys comma separated
# 4. Starts the validator
# IMPORTANT! the teku binary executes at the same time validator and beaconchain. The
# beaconchain must be executed in any case. The cronjob will kill the process if the
# to restart the container if there are public keys found

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
    --retry 2 \
    --retry-delay 2 \
    --retry-max-time 40 \
    "${HTTP_WEB3SIGNER}/eth/v1/keystores"); then
        if PUBLIC_KEYS_PARSED=$(echo ${PUBLIC_KEYS} | jq -r '.data[].validating_pubkey' | tr ' ' ','); then
            # convert array of strings to string comma separated to be used by the teku binary
            if [ ! -z "$PUBLIC_KEYS_PARSED" ]; then
                echo "${INFO} found public keys: $PUBLIC_KEYS_PARSED"
            else
                echo "${WARN} no public keys found"
            fi
        else
            echo "${WARN} something wrong happened parsing the public keys"
        fi
    else
        echo "${WARN} web3signer not available"
    fi
}

# Writes public keys to file by new line separated
# creates file if it does not exist
function write_public_keys() {
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

# Clean file
rm -rf ${PUBLIC_KEYS_FILE}
touch ${PUBLIC_KEYS_FILE}

echo "${INFO} starting cronjob"
cron

if [ ! -z "${PUBLIC_KEYS_PARSED}" ]; then
    echo "${INFO} starting teku with validator and beaconchain"
    # Write public keys to file
    write_public_keys

    exec /opt/teku/bin/teku \
    --network=prater \
    --data-base-path=/opt/teku/data \
    --eth1-endpoint=$HTTP_WEB3PROVIDER \
    --validators-external-signer-url=$HTTP_WEB3SIGNER \
    --validators-external-signer-public-keys=$PUBLIC_KEYS_PARSED \
    --p2p-port=9000 \
    --rest-api-cors-origins="*" \
    --rest-api-interface=0.0.0.0 \
    --rest-api-port=$BEACON_API_PORT \
    --rest-api-host-allowlist=* \
    --rest-api-enabled=true \
    --rest-api-docs-enabled=true \
    --initial-state=$INITIAL_STATE \
    --log-destination=CONSOLE \
    --validators-graffiti=\"$GRAFFITI\" \
    $EXTRA_OPTS
else
    echo "${WARN} web3signer not available"
    echo "${WARN} starting teku with beaconchain only"
    exec /opt/teku/bin/teku \
    --network=prater \
    --data-base-path=/opt/teku/data \
    --eth1-endpoint=$HTTP_WEB3PROVIDER \
    #--validators-external-signer-url=$HTTP_WEB3SIGNER \
    #--validators-external-signer-public-keys=$PUBLIC_KEYS_PARSED \
    --p2p-port=9000 \
    --rest-api-cors-origins="*" \
    --rest-api-interface=0.0.0.0 \
    --rest-api-port=$BEACON_API_PORT \
    --rest-api-host-allowlist=* \
    --rest-api-enabled=true \
    --rest-api-docs-enabled=true \
    --initial-state=$INITIAL_STATE \
    --log-destination=CONSOLE \
    #--validators-graffiti=\"$GRAFFITI\" \
    $EXTRA_OPTS
fi
