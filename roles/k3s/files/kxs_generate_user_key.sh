#!/bin/bash

# Taken from
# https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/#step-2-create-the-user-credentials

USERNAME=$1
NAMESPACE=$2

echo "Generating certs for '$USERNAME' in '$NAMESPACE'"
if [[ -z "$USERNAME" || -z "$NAMESPACE" ]]; then
  echo 'Please provide values for $1=USERNAME & $2=NAMESPACE'
  exit 1
fi

CA_LOCATION=/var/lib/rancher/k3s/server/tls/client-ca
CERT_AUTHORITY="$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')"

openssl genrsa -out ${USERNAME}.key 2048

openssl req -new -key ${USERNAME}.key \
    -out ${USERNAME}.csr \
    -subj "/CN=${USERNAME}/O=${NAMESPACE}"

openssl x509 -req -in ${USERNAME}.csr \
    -CA "${CA_LOCATION}.crt" \
    -CAkey "${CA_LOCATION}.key" \
    -CAcreateserial -out ${USERNAME}.crt -days 500

cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: ${NAMESPACE}
  name: namespace-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: ${NAMESPACE}
  name: namespace-admin-binding
subjects:
- kind: User
  name: ${USERNAME}
  apiGroup: ""
roleRef:
  kind: Role
  name: namespace-admin
  apiGroup: ""
EOF

cat >> config <<EOF
apiVersion: v1
clusters:
- cluster:
    server: https://knode0:6443
    certificate-authority-data: ${CERT_AUTHORITY}
  name: cluster
contexts:
- context:
    cluster: cluster
    namespace: ${NAMESPACE}
    user: ${USERNAME}
  name: ${USERNAME}-context
current-context: ${USERNAME}-context
kind: Config
preferences: {}
users:
- name: ${USERNAME}
  user:
    client-certificate: ${USERNAME}.crt
    client-key: ${USERNAME}.key
EOF

tar --remove-files -cf ${USERNAME}-${NAMESPACE}.tar *
chown ${SUDO_USER}:${SUDO_USER} ${USERNAME}-${NAMESPACE}.tar
