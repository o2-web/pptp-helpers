#!/bin/bash

# generate client name and password
client_name=$(apg -M L -n 1 -m 4 -x 6)
pass=$(apg -MCLN -a 0 -n 1 -m 8 -x 11)

new_chap_secret="$client_name"" pptpd $pass *"

echo "$new_chap_secret" >> /etc/ppp/chap-secrets

tpl='{"username":"%s","password":"%s"}'
json_response=$(printf "$tpl" "$client_name" "$pass")

echo "$json_response"

exit 0
