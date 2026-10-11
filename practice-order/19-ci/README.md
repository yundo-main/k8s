# 19. CI 검증

Pull Request와 `main` 브랜치 Push 시 Kubernetes YAML과 애플리케이션 검증을
자동화한다.

- [실습용 CI workflow](./ci.yml)
- [manifest 검사 스크립트](../21-application-test/check-manifests.sh)

실제 사용 시 `.github/workflows/ci.yml`로 복사하고 저장소의 테스트 명령을
추가한다. `.example` 파일은 자동으로 실행되지 않는다.

검증 항목은 Kubernetes YAML 문법, manifest client dry-run, 애플리케이션
테스트다.
