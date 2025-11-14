#!/bin/bash

mkdir -p users-keys

# CN -- login
# O -- user group

# [cluster-admins] admin
openssl genrsa -out users-keys/admin.key 2048
openssl req -new -key users-keys/admin.key -out users-keys/admin.csr -subj "/CN=admin/O=cluster-admins"

# ~/.minikube/ca.key should be already there
# otherwise we need creating it somehow like this:
# openssl genrsa -out ca.key 2048
# openssl req -new -x509 -key ca.key -out ca.crt -subj "/CN=Kubernetes-CA"
openssl x509 -req -in users-keys/admin.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out users-keys/admin.crt -days 365

# [security-auditors] auditor
openssl genrsa -out users-keys/auditor.key 2048
openssl req -new -key users-keys/auditor.key -out users-keys/auditor.csr -subj "/CN=auditor/O=security-auditors"
openssl x509 -req -in users-keys/auditor.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out users-keys/auditor.crt -days 365

# [developers] developer
openssl genrsa -out users-keys/developer.key 2048
openssl req -new -key users-keys/developer.key -out users-keys/developer.csr -subj "/CN=developer/O=developers"
openssl x509 -req -in users-keys/developer.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out users-keys/developer.crt -days 365

echo "Success"
