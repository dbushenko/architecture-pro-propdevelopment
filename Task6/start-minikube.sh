#!/bin/sh

minikube start

minikube cp ./audit-policy.yaml /etc/kubernetes/audit/audit-policy.yaml

minikube stop

minikube start --driver=docker --extra-config=apiserver.audit-policy-file=/etc/kubernetes/audit/audit-policy.yaml --extra-config=apiserver.audit-log-path=/tmp/audit.log 
