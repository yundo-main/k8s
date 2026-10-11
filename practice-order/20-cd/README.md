# 20. CD 배포

검증된 변경을 Docker Hub에 Push하고 Kubernetes에 배포한다.

- [CD workflow example](../../devops/chapter-03/cd.yml.example)
- [실습용 CD workflow](./cd.yml)

실제 사용 시 `.github/workflows/cd.yml`로 복사하고 Dockerfile 경로,
이미지 이름, Kubernetes 인증정보를 저장소 환경에 맞게 수정한다.

필요한 GitHub Secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBE_CONFIG
```

```bash
kubectl rollout status deployment/frontend
kubectl rollout status deployment/fastcgi-backend
kubectl get pods
```
