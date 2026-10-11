# Chapter 3. DevOps와 CI/CD

Chapter 1·2에서 만든 기존 3-Tier Kubernetes 서비스를 대상으로 테스트, 이미지
빌드, 레지스트리 Push, Kubernetes 배포를 자동화한다.

## CI/CD 흐름

```text
Git Push
  ↓
CI: YAML·코드 검증 및 테스트
  ↓
이미지 빌드
  ↓
Docker Hub Push
  ↓
CD: Kubernetes manifest 검증·적용
  ↓
Deployment rollout 확인
```

## 실습 범위

| 단계 | 내용 |
| --- | --- |
| 19 | Git 브랜치와 Pull Request 검증 |
| 20 | Kubernetes YAML 정적 검증 |
| 21 | 애플리케이션 테스트 |
| 22 | Docker 이미지 빌드·태그 |
| 23 | Docker Hub Push |
| 24 | Kubernetes 배포와 Rollout 확인 |
| 25 | 실패 시 롤백과 배포 승인 |
| 26 | GitOps 확장 |

## 예제 파일

- [`ci.yml.example`](./ci.yml.example): Pull Request용 검증 예제
- [`cd.yml.example`](./cd.yml.example): Docker Hub Push와 Kubernetes 배포 예제

`.example` 파일은 학습용 템플릿이다. 실제 GitHub Actions로 사용하려면
`.github/workflows/`로 복사하고 저장소 환경에 맞게 이미지 이름, manifest 경로,
Kubernetes 인증정보를 설정한다.

## 필수 GitHub Secrets

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBE_CONFIG
```

토큰과 kubeconfig는 YAML이나 소스 코드에 직접 저장하지 않는다.

## 기존 3-Tier와 연결

배포 대상은 기존 Kubernetes 실습의 다음 리소스를 사용한다.

- Frontend: `10-3tier/frontend.yml`
- Backend: `10-3tier/backend.yml`
- Database: `09-statefulset/statefulset.yml`
- Ingress: `11-ingress/ingress.yml`

초기 CI/CD에서는 manifest 검증과 rollout 확인부터 진행하고, 이후 애플리케이션
이미지 빌드·Push를 연결한다.
