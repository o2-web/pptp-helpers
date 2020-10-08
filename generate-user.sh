#!/bin/bash

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
json_response=$(printf "$tpl" "$client_name" "$pass")

echo "$json_response"

exit 0
