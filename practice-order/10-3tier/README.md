# 3-Tier 애플리케이션

08단계에서 실행한 `nfs-pod`와 NFS CSI StorageClass를 기반으로 09 StatefulSet의
MariaDB를 데이터 계층으로 재사용하고, 초기 이미지와 앞 단계의 ConfigMap·Secret을
연결해 3-Tier 구조를 구성한다.

이 실습은 애플리케이션을 미리 포함한 통합 이미지가 아니라 기본 런타임 이미지에
ConfigMap의 코드와 파일을 주입해 실행한다.

| 계층 | 이미지 | Kubernetes Service |
| --- | --- | --- |
| Frontend | `nginx:stable` + HTML ConfigMap | `frontend:80` |
| Backend | `python:3.12-slim` + `main.py` ConfigMap | `fastcgi-backend:8000` |
| Database | `mariadb:11` | `mariadb:3306` |

Backend 컨테이너는 시작할 때 실습에 필요한 `fastapi`, `uvicorn`, `pymysql`,
`python-multipart` 패키지를 설치한 뒤 ConfigMap의 `main.py`를 실행한다.
따라서 인터넷이 연결된 클러스터에서 실행해야 하며, 운영 환경에서는 별도의
의존성 이미지 또는 패키지 캐시를 사용한다.

Database 계층은 새로 만들지 않고
[`09-statefulset`](../09-statefulset/README.md)의 `mariadb-0`과 Headless
Service를 사용한다. MariaDB의 StatefulSet PVC는 `nfs-csi` StorageClass를 통해
`nfs-server` Pod에 연결된다. ClusterIP Service와 Kubernetes 내부 DNS로 계층 간
통신을 확인한다. 외부 노출은 다음 11단계 Ingress 실습에서 구성한다.

## 실습 구조

![초기 이미지 기반 3-Tier 구조](./3tier-overview.svg)

## 사전 조건

다음 리소스가 먼저 준비되어 있어야 한다.

1. `nfs-server`: 08단계 NFS Server Pod
2. `nfs-csi`: NFS CSI StorageClass
3. `mariadb-secret`: MariaDB 인증정보
4. `mariadb-0`: 09단계 StatefulSet Pod

NFS Pod와 StorageClass는 [`08-storage`](../08-storage/README.md), 애플리케이션
Secret은 [`07-secret`](../07-secret/README.md)에서 만든다. Frontend와 Backend
ConfigMap은 각 계층 manifest에 포함되어 있다.

## 적용

```bash
kubectl apply -f frontend.yml
kubectl apply -f backend.yml
```

상태와 내부 Service를 확인한다.

```bash
kubectl get deployment,pod,service -l app=frontend
kubectl get deployment,pod,service -l app=fastcgi-backend
kubectl get pod mariadb-0
kubectl get service frontend fastcgi-backend mariadb
```

Backend Pod에서 MariaDB Service DNS로 연결되는지 확인한다.

```bash
kubectl exec deploy/fastcgi-backend -- \
  python -c 'import socket; print(socket.gethostbyname("mariadb"))'
```

Frontend와 Backend의 ClusterIP는 다음 명령으로 확인한다.

```bash
kubectl get service frontend fastcgi-backend mariadb -o wide
```

## 삭제

```bash
kubectl delete -f backend.yml
kubectl delete -f frontend.yml
```

이 실습에서는 NFS Pod, 공용 ConfigMap, 09단계의 MariaDB StatefulSet을
재사용하므로 삭제하지 않는다.

## 원본 예제와의 관계

[`k8s/examples/frontend.yml`](../../examples/frontend.yml)과
[`k8s/examples/backend.yml`](../../examples/backend.yml)의 Deployment·Service
구조를 기준으로 한다. Backend와 Frontend는 각각의 실습 manifest에 Deployment,
ConfigMap, Service를 모두 포함한다. 외부 경로 라우팅은
[`11-ingress`](../11-ingress/README.md)에서 관리한다.
Backend는 이 실습의
[`backend.yml`](./backend.yml)에 Deployment, ConfigMap, Service를 모두 포함한다.
Frontend도 [`frontend.yml`](./frontend.yml)에 Deployment, ConfigMap, Service를
모두 포함한다.

ConfigMap 생성만 별도로 연습하려면
[`06-configmap/frontend.yml`](../06-configmap/frontend.yml) 또는
[`06-configmap/backend.yml`](../06-configmap/backend.yml)을 사용한다. 단, 3-Tier
실습에서는 같은 이름의 ConfigMap을 중복 적용하지 않는다.

## Chapter 2 확장 예제

기존 3-Tier를 기준으로 다음 단계의 고급 실습을 이어서 적용할 수 있다.

- [Security RBAC](../14-security/3tier-backend-rbac.yml): Backend ServiceAccount와 권한
- [MariaDB 백업 CronJob](../15-batch/3tier-mariadb-backup.yml): NFS PVC에 데이터 백업
- [ResourceQuota·LimitRange](../17-cluster-scoped/3tier-limits.yml): Namespace 자원 제한
- [Custom Resource](../18-extension/3tier-backup-cr.yml): 3-Tier 백업 정책 API 모델
