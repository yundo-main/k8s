# 25. 롤백과 배포 승인

운영 환경 배포 전 승인 단계를 두고, 장애 시 이전 revision으로 되돌린다.

```bash
kubectl rollout history deployment/fastcgi-backend
kubectl rollout undo deployment/fastcgi-backend
kubectl rollout status deployment/fastcgi-backend --timeout=180s
```

- [승인 후 롤백 스크립트](./rollback.sh)

GitHub Actions에서는 `production` Environment에 Required reviewers를 설정하고,
CD 작업의 `environment: production`으로 승인 절차를 연결한다.
