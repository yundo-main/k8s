# StatefulSet

고유한 네트워크 식별자와 지속적인 스토리지가 필요한
애플리케이션을 관리한다.

## MariaDB StatefulSet 실습

[`statefulset.yml`](./statefulset.yml)은 MariaDB 1개를 StatefulSet으로 실행하는
학습용 구성이다.

적용 전에 [`08-storage`](../08-storage/README.md)의 NFS CSI Driver 설치와
`nfs-csi` StorageClass 준비를 완료한다. StatefulSet의
`volumeClaimTemplates`가 이 StorageClass를 사용해 전용 PVC를 생성한다.

- `Secret`: MariaDB 초기화용 비밀번호와 데이터베이스 정보 제공
- `ConfigMap`: 최초 초기화 시 실행할 `init.sql` 제공
- Headless Service: `mariadb-0.mariadb` 형태의 고정 DNS 제공
- `volumeClaimTemplates`: `mariadb-0` 전용 PVC 자동 생성

### Headless Service를 사용하는 이유

MariaDB StatefulSet에서는 각 Pod를 개별 식별해야 하므로 Headless Service를
사용한다. `clusterIP: None`인 `mariadb` Service는 가상 IP 하나로 요청을
분산하는 대신 StatefulSet Pod의 DNS 레코드를 제공한다.

- `mariadb-0.mariadb`처럼 Pod별 안정적인 DNS 이름을 제공한다.
- Pod가 재생성되어 IP가 바뀌어도 애플리케이션이 동일한
  DNS 이름을 사용할 수 있다.
- 데이터베이스 복제나 클러스터링에서 구성원별 연결 대상을
  구분할 수 있다.
- 클라이언트가 여러 Pod 주소를 확인해 자체 연결 선택·부하분산을
  수행할 수 있다.

즉, 일반적인 웹 트래픽 분산보다 StatefulSet의 고정 식별과
서비스 디스커버리에 초점을 둔 Service다.

구조:

![MariaDB StatefulSet 구조](./mariadb.svg)

구성 파일:

1. [`../07-secret/secret.yml`](../07-secret/secret.yml): MariaDB 인증정보
2. [`../06-configmap/configmap.yml`](../06-configmap/configmap.yml): 최초 실행 SQL
3. [`../05-service/service.yml`](../05-service/service.yml): Headless Service
4. [`statefulset.yml`](./statefulset.yml): MariaDB StatefulSet (`nfs-csi` PVC)

스토리지 선행 실습:
[`../08-storage/README.md`](../08-storage/README.md)

### 실행 및 확인

```bash
kubectl apply -f ../07-secret/secret.yml
kubectl apply -f ../06-configmap/configmap.yml
kubectl apply -f ../05-service/service.yml
kubectl apply -f statefulset.yml
kubectl rollout status statefulset/mariadb
kubectl get statefulset mariadb
kubectl get pod mariadb-0 -o wide
kubectl get pvc
kubectl get service mariadb
```

MariaDB 접속 테스트:

```bash
kubectl exec -it mariadb-0 -- mariadb -u root -prootpass -e "SHOW DATABASES;"
kubectl exec -it mariadb-0 -- mariadb -u fcgiuser -pfcgipass fcgidb -e "SHOW TABLES;"
```

StatefulSet Pod의 고정 DNS 확인:

```bash
kubectl run dns-test --rm -it --restart=Never --image=busybox:1.36 -- nslookup mariadb-0.mariadb
```

### 삭제

StatefulSet과 함께 생성된 PVC는 데이터 보존을 위해 자동 삭제되지 않는다.

```bash
kubectl delete -f statefulset.yml
kubectl delete -f ../05-service/service.yml
kubectl delete -f ../06-configmap/configmap.yml
kubectl delete -f ../07-secret/secret.yml
kubectl get pvc
```

실습 데이터를 완전히 삭제할 때만 다음 명령을 실행한다.

```bash
kubectl delete pvc mariadb-data-mariadb-0
```

> `k8s/examples/db.yml`의 Deployment 방식과 동시에 적용하지 않는다. 두 구성은
> 같은 `mariadb` 리소스 이름을 사용한다.
