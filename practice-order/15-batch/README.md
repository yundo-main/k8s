# Job

일회성 작업을 실행하고 지정된 성공 횟수를 만족하면 완료 상태로 유지한다.

## 기존 3-Tier MariaDB 백업

[`3tier-mariadb-backup.yml`](./3tier-mariadb-backup.yml)은 매일 02시에
`mariadb` Service로 접속해 `fcgidb`를 덤프하고 `nfs-test-pvc`에 저장한다.

```bash
kubectl apply -f 3tier-mariadb-backup.yml
kubectl get cronjob mariadb-backup
kubectl create job --from=cronjob/mariadb-backup mariadb-backup-now
kubectl get job,pod -l job-name=mariadb-backup-now
```

> `nfs-test-pvc`가 먼저 Bound 상태여야 한다. 운영 환경에서는 백업 보존기간,
> 암호화, 외부 백업 저장소를 별도로 설계한다.
