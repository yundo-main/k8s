# 보안 오브젝트

서비스 계정과 RBAC 권한을 관리한다.

## 기존 3-Tier Backend 예제

[`3tier-backend-rbac.yml`](./3tier-backend-rbac.yml)은 Backend가 같은 Namespace의
Service와 Endpoint를 조회할 수 있는 ServiceAccount·Role·RoleBinding을 구성한다.

```bash
kubectl apply -f 3tier-backend-rbac.yml
kubectl get serviceaccount fastcgi-backend
kubectl get role fastcgi-backend-reader
kubectl get rolebinding fastcgi-backend-reader
```

현재 Backend 코드는 Kubernetes API를 직접 호출하지 않으므로, 실서비스에서는
필요한 권한만 부여하고 ServiceAccount 토큰 자동 마운트를 검토한다.
