#!/bin/bash

kubectl delete networkpolicy --all
kubectl apply -f all-policies.yaml

echo "Success"
