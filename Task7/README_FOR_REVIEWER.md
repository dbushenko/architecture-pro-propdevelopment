# Запуск minikube

   ```bash
   minikube
   kubectl apply -f secure-manifests
   kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.13/deploy/gatekeeper.yaml
   kubectl apply -f gatekeeper/constraint-templates/
   kubectl apply -f gatekeeper/constraints
   ```

## Проверка работы системы

   ```bash
   ./verify/verify-admission.sh
   ./verify/validate-security.sh
   ```

