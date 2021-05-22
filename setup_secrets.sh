#!/bin/bash

# Require a file with a plaintext password called '.vault'

# Contains the exported secret values
source .vars

cat >> "group_vars/all" <<EOF
# Email used by cert-manager to to notify you
# if there were issues registering the certificate
EOF
ansible-vault encrypt_string --vault-id .vault --name email "$EMAIL" >> "group_vars/all"
ansible-vault encrypt_string --vault-id .vault --name domain "$DOMAIN" >> "group_vars/all"
ansible-vault encrypt_string --vault-id .vault --name git_username "$GIT_USERNAME" >> "group_vars/all"
ansible-vault encrypt_string --vault-id .vault --name git_token "$GIT_TOKEN" >> "group_vars/all"
