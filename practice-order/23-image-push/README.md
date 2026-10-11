# 23. Docker Hub Push

빌드한 이미지를 Docker Hub에 Push한다.

```bash
read -s DOCKER_PAT
echo
echo "$DOCKER_PAT" | docker login --username jarrodkim --password-stdin
docker push jarrodkim/fastapi-backend:"$IMAGE_TAG"
unset DOCKER_PAT
```

- [Push 스크립트](./push.sh)

토큰은 명령이나 YAML에 직접 저장하지 않는다. GitHub Actions에서는
`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` Secrets를 사용한다.
