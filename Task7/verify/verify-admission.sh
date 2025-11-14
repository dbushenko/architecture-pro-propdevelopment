#!/bin/bash

# Скрипт для проверки работы политик безопасности
echo "Проверка работы политик безопасности в namespace audit-zone..."

# Проверяем, что небезопасные поды отклоняются
echo "1. Проверка отклонения привилегированного контейнера..."
result=$(kubectl apply -f /home/dim/Work/architecture-pro-propdevelopment/Task7/insecure-manifests/01-privileged-pod.yaml 2>&1 | grep -c "forbidden\|denied\|violate")
if [ $result -gt 0 ]; then
    echo "   ✓ Привилегированный контейнер успешно отклонен"
else
    echo "   ✗ Привилегированный контейнер не был отклонен"
fi

echo "2. Проверка отклонения hostPath volume..."
result=$(kubectl apply -f /home/dim/Work/architecture-pro-propdevelopment/Task7/insecure-manifests/02-hostpath-pod.yaml 2>&1 | grep -c "forbidden\|denied\|violate")
if [ $result -gt 0 ]; then
    echo "   ✓ HostPath volume успешно отклонен"
else
    echo "   ✗ HostPath volume не был отклонен"
fi

echo "3. Проверка отклонения контейнера от root..."
result=$(kubectl apply -f /home/dim/Work/architecture-pro-propdevelopment/Task7/insecure-manifests/03-root-user-pod.yaml 2>&1 | grep -c "forbidden\|denied\|violate")
if [ $result -gt 0 ]; then
    echo "   ✓ Контейнер от root успешно отклонен"
else
    echo "   ✗ Контейнер от root не был отклонен"
fi

# Проверяем, что безопасные поды проходят валидацию
echo "4. Проверка создания безопасного пода..."
if kubectl apply -f /home/dim/Work/architecture-pro-propdevelopment/Task7/secure-manifests/01-secure.yaml; then
    echo "   ✓ Безопасный под успешно создан"
else
    echo "   ✗ Безопасный под не был создан"
fi

echo "Проверка завершена."