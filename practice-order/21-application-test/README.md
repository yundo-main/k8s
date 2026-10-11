# 21. 애플리케이션 테스트

CI 단계에서 FastAPI 애플리케이션 테스트를 실행한다.

## 예시

- [manifest 검사 스크립트](./check-manifests.sh)

```yaml
- name: Install test dependencies
  run: pip install -r backend/requirements.txt pytest

- name: Run backend tests
  run: pytest backend/tests
```

실제 저장소의 테스트 경로와 의존성 파일에 맞게 수정한다. 현재 실습 파일은
Kubernetes manifest 검사를 수행한다. 테스트가 실패하면
이미지 빌드와 배포 단계로 진행하지 않는다.
