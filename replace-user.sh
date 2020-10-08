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
# new_client_response="$(source ./generate-user.sh)"

# generate client name and password
client_name=$(apg -M L -n 1 -m 4 -x 6)
pass=$(apg -MCLN -a 0 -n 1 -m 8 -x 11)

if [[ -z "$client_name" || -z "$pass" ]]; then
    echo "failed to generate credentials"
    exit 1
fi

new_chap_secret="$client_name"" pptpd $pass *"

# add new line to chap-secrets
echo "$new_chap_secret" >> /etc/ppp/chap-secrets

existing_chap_secret="$(grep "${client_name} pptpd " /etc/ppp/chap-secrets)"
if [[ -z "$existing_chap_secret" ]]; then
    echo "failed to add chap-secret"
    exit 1
fi

tpl='{"username":"%s","password":"%s"}'
new_client_response=$(printf "$tpl" "$client_name" "$pass")

if jq -e . >/dev/null 2>&1 <<<"$json_string"; then
    echo "parsed JSON successfully"
else
    echo "error: failed to parse JSON";
    exit 1
fi

# revoke openvpn user
cd /etc/openvpn/easy-rsa/
./easyrsa --batch revoke "$old_client"
EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
rm -f "/root/$old_client.ovpn"

# create a new openvpn user
cd /
MENU_OPTION="1" CLIENT="$client_name" PASS="1" ./openvpn-install.sh
chmod 777 "/root/$client_name.ovpn"

echo "$new_client_response"

exit 0
