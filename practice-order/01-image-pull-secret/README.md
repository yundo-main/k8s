# Secret

비밀번호, 토큰, 인증서 등 민감한 데이터를 관리한다.
Base64 인코딩은 암호화가 아니므로 저장소에 평문 Secret을 커밋하지 않는다.

## Docker Hub 로그인 Secret

Private Docker Hub 이미지를 Kubernetes 노드가 가져오도록 `docker-registry`
타입의 Secret을 생성한다. `DOCKER_HUB_ACCESS_TOKEN`에는 Docker Hub에서 생성한
Personal Access Token을 사용한다.

YAML 템플릿: [`dockerhub-secret.example.yml`](./dockerhub-secret.example.yml)

템플릿을 복사해 실제 토큰으로 바꾼 뒤 적용할 수 있다.

```bash
cp dockerhub-secret.example.yml dockerhub-secret.yml
# dockerhub-secret.yml의 REPLACE_WITH_DOCKER_HUB_ACCESS_TOKEN을 실제 토큰으로 변경
kubectl apply -f dockerhub-secret.yml
```

실제 파일은 저장소에 커밋하지 않는다. 명령으로 직접 생성하는 방법도 있다.

```bash
read -s DOCKER_PAT
echo

kubectl create secret docker-registry jarrod-secret-test \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=jarrodkim \
  --docker-password="$DOCKER_PAT" \
  --docker-email='YOUR_EMAIL'

unset DOCKER_PAT
```

Secret은 생성한 Namespace에서만 사용할 수 있다. Pod 또는 Deployment에서
다음과 같이 참조한다.

```yaml
spec:
  imagePullSecrets:
    - name: jarrod-secret-test
```

Secret 확인:

```bash
kubectl get secret jarrod-secret-test
kubectl describe secret jarrod-secret-test
```

토큰과 Secret YAML은 저장소에 커밋하지 않는다. 테스트가 끝나면 필요에 따라
다음 명령으로 삭제한다.

```bash
kubectl delete secret jarrod-secret-test
```
