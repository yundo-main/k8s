# Kubernetes 실습 순서

이 디렉터리는 설치가 완료된 Kubernetes 클러스터에서 실습 파일을 순서대로
실행하는 학습 경로다.

클러스터 설치는 별도 트랙인 [install](../install/plan.md)에서 진행한다.
`examples/`는 실습 파일 생성을 위한 내부 기반 예제이므로 학습 경로에 포함하지
않는다.

## 챕터 구성

- [Chapter 1. Kubernetes 기본 구성과 3-Tier 구축](./chapter-01/README.md)
- [Chapter 2. 서비스 고도화와 보안](./chapter-02/README.md)
- [Chapter 3. DevOps와 CI/CD](./chapter-03/README.md)

## 전체 순서

```text
설치 완료
  ↓
01 이미지 Pull Secret
  ↓
02 Pod
  ↓
03 ReplicaSet
  ↓
04 Deployment
  ↓
05 Service
  ↓
06 ConfigMap
  ↓
07 애플리케이션 Secret
  ↓
08 Persistent Storage
  ↓
09 StatefulSet
  ↓
10 3-Tier Application
  ↓
11 Ingress
  ↓
12 NetworkPolicy
  ↓
13 Probe·Scale
  ↓
14 Security
  ↓
15 Batch Workload
  ↓
16 DaemonSet
  ↓
17 Cluster-scoped Resource
  ↓
18 Extension
  ↓
19 CI 검증
  ↓
20 CD 배포
  ↓
21~26 DevOps 확장
  ↓
27~32 DevSecOps
  ↓
Addons·Operations
```

## Chapter 1. Kubernetes 기본 구성과 3-Tier 구축

01~10단계는 기본 리소스 학습과 3-Tier 내부 구성까지 진행한다.

## 1. 설치 후 클러스터 확인

설치가 끝난 뒤 노드와 시스템 Pod가 정상인지 확인한다.

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp
```

모든 노드가 `Ready`이고 CNI 관련 Pod가 정상이어야 다음 단계로 진행한다.

Chapter 1은 01~10단계, Chapter 2는 11~18단계로 구성한다.

## 01. Docker Hub 이미지 Pull Secret

[01-image-pull-secret](./01-image-pull-secret/README.md)의 명령으로 Private
이미지 Pull Secret을 생성한다.

```bash
read -s DOCKER_PAT
echo

kubectl create secret docker-registry jarrod-secret-test \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=jarrodkim \
  --docker-password="$DOCKER_PAT" \
  --docker-email='YOUR_EMAIL'

unset DOCKER_PAT
kubectl get secret jarrod-secret-test
```

이 Secret은 이미지 Pull 인증용이다. MariaDB 비밀번호용 Secret은 07단계에서
별도로 사용한다. Secret은 Namespace별로 생성해야 한다.

## 실습 이미지 정책

Storage·ConfigMap 이전 단계는 설정이 이미지에 포함된 테스트 이미지를 사용한다.

| 역할 | 이미지 |
| --- | --- |
| Frontend·Nginx | `jarrodkim/nginx-test:latest` |
| Backend·FastAPI | `jarrodkim/fastapi-test:latest` |
| Database·MariaDB | `jarrodkim/mariadb-test:latest` |

09 StatefulSet 단계부터는 `mariadb:11`과 ConfigMap·Secret·PVC를 조합해
이미지와 실행 설정을 분리한다.

## 02. Pod

[02-pod](./02-pod/README.md)에서 단일 Pod와 컨테이너 간 통신을 실습한다.

```bash
kubectl apply -f k8s/practice-order/02-pod/1container.yml
kubectl get pod -o wide
kubectl delete -f k8s/practice-order/02-pod/1container.yml
```

2컨테이너와 3컨테이너 예제는 [02-pod](./02-pod/)에서 확인한다.

## 03. ReplicaSet

[03-replicaset](./03-replicaset/README.md)에서 지정한 Pod 복제본 수를 유지한다.

```bash
kubectl apply -f k8s/practice-order/03-replicaset/nginx.yml
kubectl get rs,pods -l app=nginx-replicaset
kubectl scale rs nginx-replicaset --replicas=5
kubectl delete -f k8s/practice-order/03-replicaset/nginx.yml
```

## 04. Deployment

[04-deployment](./04-deployment/README.md)에서 ReplicaSet 관리, 롤링 업데이트,
롤백과 스케일링을 실습한다.

```bash
kubectl apply -f k8s/practice-order/04-deployment/nginx.yml
kubectl rollout status deployment/nginx-deployment
kubectl get deployment,rs,pods -l app=nginx-deployment
kubectl rollout history deployment/nginx-deployment
kubectl delete -f k8s/practice-order/04-deployment/nginx.yml
```

## 05. Service

[05-service](./05-service/README.md)에서 변경되는 Pod IP를 고정된 Service
엔드포인트로 연결한다.

## 06. ConfigMap

[06-configmap](./06-configmap/README.md)에서 일반 설정과 초기화 SQL을 이미지와
분리한다. MariaDB 초기화 파일은 [configmap.yml](./06-configmap/configmap.yml)에
있다.

## 07. 애플리케이션 Secret

[07-secret](./07-secret/README.md)에서 애플리케이션 인증정보를 별도 Secret으로
관리한다. 이미지 Pull Secret과 용도를 구분한다.

## 08. Persistent Storage

[08-storage](./08-storage/README.md)에서 NFS Server Pod, NFS CSI Driver,
StorageClass, PVC의 관계를 확인한다.

## 09. StatefulSet

[09-statefulset](./09-statefulset/README.md)에서 고정 Pod 이름, Headless Service,
ConfigMap, Secret, PVC를 MariaDB에 조합한다.

```bash
kubectl apply -f k8s/practice-order/08-storage/nfs-pod.yml
kubectl apply -f k8s/practice-order/08-storage/nfs-service.yml
kubectl apply -f k8s/practice-order/08-storage/nfs-storageclass.yml
kubectl apply -f k8s/practice-order/08-storage/nfs-pvc.yml
kubectl apply -f k8s/practice-order/07-secret/secret.yml
kubectl apply -f k8s/practice-order/06-configmap/configmap.yml
kubectl apply -f k8s/practice-order/05-service/service.yml
kubectl apply -f k8s/practice-order/09-statefulset/statefulset.yml
kubectl rollout status statefulset/mariadb
kubectl get statefulset,pod,pvc,service
```

실습 종료 시 StatefulSet과 연결 리소스를 삭제한다. PVC는 데이터 보존을 위해
별도로 삭제한다.

```bash
kubectl delete -f k8s/practice-order/09-statefulset/statefulset.yml
kubectl delete -f k8s/practice-order/05-service/service.yml
kubectl delete -f k8s/practice-order/06-configmap/configmap.yml
kubectl delete -f k8s/practice-order/07-secret/secret.yml
kubectl delete pvc mariadb-data-mariadb-0
```

## 10. 3-Tier Application

[10-3tier](./10-3tier/)에서 09단계의 MariaDB StatefulSet과 초기
Frontend·Backend 이미지를 연결하고 내부 ClusterIP Service 통신을 확인한다.

## Chapter 2. 서비스 고도화와 보안

11~18단계는 외부 노출, 네트워크 제어, 가용성, 보안과 확장 리소스를 다룬다.

## 11. Ingress

[11-ingress](./11-ingress/)에서 Ingress Controller 상태와 `nginx` IngressClass를
확인하고, `/`와 `/api/` 경로 라우팅을 통해 3-Tier를 외부에 노출한다.

## 12. NetworkPolicy

[12-networkpolicy](./12-networkpolicy/)에서 Pod 간 ingress·egress 네트워크 정책과
EndpointSlice를 학습한다.

## 13. Probe·Scale

[13-probe-scale](./13-probe-scale/)에서 readiness/liveness, PDB, PriorityClass,
HPA를 학습한다.

## 14. Security

[14-security](./14-security/)에서 ServiceAccount, Role, RoleBinding,
ClusterRole을 학습한다.

## 15. Batch Workload

[15-batch](./15-batch/)에서 Job과 CronJob을 학습한다.

## 16. DaemonSet

[16-daemonset](./16-daemonset/)에서 노드별 Pod 실행을 학습한다.

## 17. Cluster-scoped Resource

[17-cluster-scoped](./17-cluster-scoped/)에서 Node, Namespace, ResourceQuota,
LimitRange 등을 학습한다.

## 18. Extension

[18-extension](./18-extension/)에서 CRD와 Custom Resource를 학습한다.

## Addons·Operations

기본 리소스 학습 이후 다음 영역으로 확장한다.

- [Addon·Operations 이론](../theory/addons-operations.md)
- [Addons](../addons/README.md): CNI, Ingress, Storage, Operator
- [Operations](../operations/README.md): 클러스터·노드·네트워크·장애 대응

## Chapter 3. DevOps와 CI/CD

Kubernetes 실습 결과를 대상으로 CI 검증, Docker 이미지 빌드·Push, 배포와
Rollout 확인을 자동화한다.

- [DevOps·CI/CD 실습](./chapter-03/README.md)

## 주의사항

- `k8s/install/`과 `k8s/examples/`는 이 학습 디렉터리의 실습 파일로 이동하지 않는다.
- `k8s/examples/`는 실습 파일 생성을 위한 내부 기반 예제다.
- 테스트용 `latest` 태그는 이미지 변경으로 결과가 달라질 수 있다.
- Secret 값과 kubeconfig는 저장소에 커밋하지 않는다.
- 기존 `k8s/examples/db.yml`과 StatefulSet MariaDB 예제를 동시에 적용하지 않는다.
