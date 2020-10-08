#!/bin/bash

old_client="${CLIENT}"

if [[ -z "$old_client" ]]; then
    echo "error: empty client name"
    exit 1
fi

existing_chap_secret="$(grep "${old_client} pptpd " /etc/ppp/chap-secrets)"

if [[ -z "$existing_chap_secret" ]]; then
    echo "error: client not found"
    exit 1
fi

# delete old user
deleted=$(./delete-user.sh)

if [[ "$deleted" != "ok" ]]; then
    echo "error: $deleted"
    exit 1
fi

echo "deleted chap-secret: $existing_chap_secret"

# generate a new user
new_client_response="$(./generate-user.sh)"

if jq -e . >/dev/null 2>&1 <<<"$new_client_response"; then
    # echo "Parsed JSON successfully and got something other than false/null"
else
    echo "error: failed to parse JSON, or got false/null"
    exit 1
fi

echo "$new_client_response"

exit 0
