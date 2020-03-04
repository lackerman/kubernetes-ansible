#!/bin/sh

[ -z "$1" ] && echo "please provide your domain (example.com) as a parameter to the script"

CERT_NAME="$1-wildcard-crt"
HOST="*.$1"
KEY_FILE="$1-wildcard.key"
CERT_FILE="$1-wildcard.crt"

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 -keyout "${KEY_FILE}" -out "${CERT_FILE}" \
  -subj "/CN=${HOST}/O=${HOST}"

kubectl create secret tls "${CERT_NAME}" --key "${KEY_FILE}" --cert "${CERT_FILE}"
kubectl create secret tls registry --key privkey1.pem --cert cert1.pem

