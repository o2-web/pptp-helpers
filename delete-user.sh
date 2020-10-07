#!/bin/bash

old_client="${CLIENT}"

if [[ -z "$old_client" ]]; then
    echo "empty client name"
    exit 1
fi

# delete old client
rm -f /etc/ppp/chap-secrets.bak
cp /etc/ppp/chap-secrets /etc/ppp/chap-secrets.bak
sed -i "/^${old_client} pptpd /d" /etc/ppp/chap-secrets

existing_chap_secret="$(grep "${old_client} pptpd " /etc/ppp/chap-secrets)"

if [[ -z "$existing_chap_secret" ]]; then
    echo "ok"
    exit 0
fi

echo "failed to delete client"
exit 1
