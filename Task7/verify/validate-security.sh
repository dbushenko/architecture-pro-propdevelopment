#!/bin/bash

# Скрипт для проверки соответствия политикам безопасности

echo "Проверка соответствия манифестов политикам безопасности..."

# Проверяем, что все безопасные поды созданы
echo "1. Проверка наличия безопасных подов..."
for pod in "secure-privileged-pod" "secure-hostpath-pod" "secure-root-user-pod"; do
    if kubectl get pod $pod -n audit-zone &> /dev/null; then
        echo "   ✓ Под $pod существует"
    else
        echo "   ✗ Под $pod отсутствует"
    fi
done

# Проверяем, что Gatekeeper активен
echo "2. Проверка активности Gatekeeper..."
if kubectl get pod -n gatekeeper-system | grep -q "gatekeeper-controller-manager"; then
    echo "   ✓ Gatekeeper активен"
else
    echo "   ✗ Gatekeeper неактивен"
fi

# Проверяем, что PodSecurity Admission включён
echo "3. Проверка настроек namespace audit-zone..."
if kubectl get namespace audit-zone -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' | grep -q "restricted"; then
    echo "   ✓ PodSecurity Admission включён и действует"
else
    echo "   ✗ PodSecurity Admission отсутствует или настроен некорректно"
fi

# Проверяем работу constraint-ов
echo "4. Проверка работы constraint-ов..."
if kubectl get constrainttemplates | grep -q "k8sprivilegedcontainers\|k8shostpath\|k8srunasnonroot"; then
    echo "   ✓ Constraint-ы активны"
else
    echo "   ✗ Constraint-ы отсутствуют"
fi

echo "Проверка завершена."