# 보안 오브젝트

서비스 계정과 RBAC 권한을 관리한다.

![RBAC 권한 흐름과 검증](./rbac-overview.svg)

## 기존 3-Tier Backend 예제

[`3tier-backend-rbac.yml`](./3tier-backend-rbac.yml)은 Backend가 같은 Namespace의
Service와 Endpoint를 조회할 수 있는 ServiceAccount·Role·RoleBinding을 구성한다.

```bash
kubectl apply -f 3tier-backend-rbac.yml
kubectl get serviceaccount fastcgi-backend
kubectl get role fastcgi-backend-reader
kubectl get rolebinding fastcgi-backend-reader
```

## 상세 실습 검증

모든 명령은 저장소 루트인 `k8s` 디렉터리에서 실행한다. 기존 3-Tier와
분리된 Namespace에서 권한을 검증한다.

### 1. Namespace와 RBAC 리소스 생성

```bash
export KUBECONFIG=/Users/jarrod/.kube/k8s-config
export RBAC_NAMESPACE=k8s-rbac-practice
kubectl create namespace "$RBAC_NAMESPACE"

kubectl apply \
  --namespace "$RBAC_NAMESPACE" \
  -f practice-order/14-security/3tier-backend-rbac.yml

kubectl -n "$RBAC_NAMESPACE" get \
  serviceaccount/fastcgi-backend \
  role/fastcgi-backend-reader \
  rolebinding/fastcgi-backend-reader
```

이미 Namespace가 있으면 `AlreadyExists`는 무시하고 다음 단계로 진행한다.

### 2. 허용 권한 검증

`--namespace`와 `--as`를 반드시 함께 지정한다.

```bash
kubectl auth can-i get services \
  --namespace "$RBAC_NAMESPACE" \
  --as="system:serviceaccount:${RBAC_NAMESPACE}:fastcgi-backend"

kubectl auth can-i list endpoints \
  --namespace "$RBAC_NAMESPACE" \
  --as="system:serviceaccount:${RBAC_NAMESPACE}:fastcgi-backend"
```

예상 결과:

```text
yes
yes
```

### 3. 비허용 권한 검증

Role에 Secret과 Pod 권한을 추가하지 않았으므로 모두 `no`여야 한다.

```bash
kubectl auth can-i get secrets \
  --namespace "$RBAC_NAMESPACE" \
  --as="system:serviceaccount:${RBAC_NAMESPACE}:fastcgi-backend"

kubectl auth can-i get pods \
  --namespace "$RBAC_NAMESPACE" \
  --as="system:serviceaccount:${RBAC_NAMESPACE}:fastcgi-backend"
```

예상 결과:

```text
no
no
```

### 4. 권한 규칙 상세 확인

```bash
kubectl -n "$RBAC_NAMESPACE" describe role fastcgi-backend-reader
kubectl -n "$RBAC_NAMESPACE" describe rolebinding fastcgi-backend-reader
kubectl auth can-i --list \
  --namespace "$RBAC_NAMESPACE" \
  --as="system:serviceaccount:${RBAC_NAMESPACE}:fastcgi-backend"
```

`--list` 결과에서 `services`와 `endpoints`에 `get`, `list`만 허용되는지 확인한다.

### 5. 정리

```bash
kubectl delete namespace "$RBAC_NAMESPACE"
unset RBAC_NAMESPACE
```

현재 Backend 코드는 Kubernetes API를 직접 호출하지 않으므로, 실서비스에서는
필요한 권한만 부여하고 ServiceAccount 토큰 자동 마운트를 검토한다.
ServiceAccount를 Deployment에 연결하지 않으면 이 리소스는 권한 실습용으로만
존재하며, 기존 Backend Pod의 실행 권한은 변경되지 않는다.
