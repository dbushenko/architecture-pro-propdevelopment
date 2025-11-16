# Анализ audit.log

## Подозрительные события

1. Доступ к секретам:
   - Кто: minikube-user
   - Где: kube-system namespace
   - Почему подозрительно: В audit log есть события, где пользователь minikube-user, обладающий правами system:masters, выполняет операции чтения секретов в namespace kube-system. Это может быть использовано для получения конфиденциальной информации.
   - Пример:
   {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"RequestResponse","auditID":"b72167d6-8c63-4f1e-b0bb-303f73981b1d","stage":"RequestReceived","requestURI":"/api/v1/namespaces/kube-system/secrets?limit=500","verb":"list","user":{"username":"minikube-user","groups":["system:masters","system:authenticated"],"extra":{"authentication.kubernetes.io/credential-id":["X509SHA256=aa4a82b2232f9e7c41e3c7c5fe404b20575b4b4ff8d5ffaf3be4d8af9c338cfa"]}},"sourceIPs":["192.168.49.1"],"userAgent":"kubectl/v1.34.1 (linux/amd64) kubernetes/93248f9","objectRef":{"resource":"secrets","namespace":"kube-system","apiVersion":"v1"},"requestReceivedTimestamp":"2025-10-19T14:41:14.016597Z","stageTimestamp":"2025-10-19T14:41:14.016597Z"}

2. Привилегированные поды:
   - Кто: minikube-user
   - Комментарий: Создание пода с привилегированным контейнером (securityContext.privileged=true) в namespace secure-ops. Это позволяет контейнеру получить полный доступ к хост-системе, что может быть использовано для эскалации привилегий.
   - Пример (часть лога пропустил, т.к. слишком длинный):
   {"kind":"Event","apiVersion":"audit.k8s.io/v1","level . . . share/ca-certificates","type":"DirectoryOrCreate"}}],"containers":[{"name":"kube-apiserver","image":"registry.k8s.io/kube-apiserver:v1.33.1","command":["kube-apiserver","--advertise-address=192.168.49.2","--allow-privileged=true","--audit-log-path=-","--audit-policy-file=/etc/ssl/certs/audit-policy.yaml","--authorization-mode=Node,RBAC","--client-ca-file=/var/lib/minikube/certs/ca.crt","--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota","--enable-bootstrap-token-auth=true","--etcd-cafile=/var/lib/minikube/certs/etcd/ca.crt", . . .}}

3. Использование kubectl exec в чужом поде:
   - Кто: minikube-user
   - Что делал: Использовал kubectl exec для выполнения команды в поде coredns-674b8bbfcf-dtdtm в namespace kube-system. Это может быть попыткой проникновения в системные компоненты кластера.
   - Пример (здесь пользователь читал командой cat файл /etc/resolv.conf):
   {"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"1b0ad713-c643-441e-af7b-1076dead425d","stage":"RequestReceived","requestURI":"/api/v1/namespaces/kube-system/pods/coredns-674b8bbfcf-dtdtm/exec?command=cat\u0026command=%2Fetc%2Fresolv.conf\u0026container=coredns\u0026stderr=true\u0026stdout=true","verb":"get","user":{"username":"minikube-user","groups":["system:masters","system:authenticated"],"extra":{"authentication.kubernetes.io/credential-id":["X509SHA256=aa4a82b2232f9e7c41e3c7c5fe404b20575b4b4ff8d5ffaf3be4d8af9c338cfa"]}},"sourceIPs":["192.168.49.1"],"userAgent":"kubectl/v1.34.1 (linux/amd64) kubernetes/93248f9","objectRef":{"resource":"pods","namespace":"kube-system","name":"coredns-674b8bbfcf-dtdtm","apiVersion":"v1","subresource":"exec"},"requestReceivedTimestamp":"2025-10-19T14:41:14.630152Z","stageTimestamp":"2025-10-19T14:41:14.630152Z"}

4. Создание RoleBinding с правами cluster-admin:
   - Кто: -
   - Где: не обнаружено
   - К чему привело: такие действия могут привести к эскалации привилегий, если недоверенный пользователь получает права cluster-admin.

5. Удаление audit-policy.yaml:
   - Кто: -
   - Где: не обнаружено
   - Возможные последствия: удаление файлов политики аудита может скрыть следы атаки и затруднить расследование инцидента.

## Вывод

Найдены несколько подозрительных действий:
- Доступ к системным секретам в namespace kube-system
- Создание привилегированного пода, что позволяет получить расширенные права доступа к хост-системе
- Использование kubectl exec для взаимодействия с подом критичного системного компонента (coredns)

Эти действия указывают на потенциальную попытку компрометации кластера. Пользователь minikube-user имеет широкие права (входит в группу system:masters), что позволяет ему выполнять опасные операции.

Рекомендуется:
1. Проанализировать и ограничить права пользователя minikube-user, если они превышают необходимый уровень доступа
2. Внедрить более строгую политику RBAC для ограничения доступа к чувствительным ресурсам
3. Включить подробное аудирование и мониторинг подозрительных действий
4. Регулярно проверять конфигурации подов на наличие привилегированных контейнеров и других уязвимостей безопасности
