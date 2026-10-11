# Kubernetes 학습 및 운영 문서

이 디렉터리는 Kubernetes 설치, 학습 실습, 클러스터 확장, 운영 명령을 역할별로
분리해 관리한다.

- [Kubernetes 실습 순서](./practice-order/README.md)
- [Addon·Operations 이론](./theory/addons-operations.md)

## 디렉터리 구조

```text
k8s/
├── install/        # Ansible 기반 Kubernetes 설치와 단계별 SVG
├── practice-order/ # 학습 순서별 실제 실습 파일
├── addons/         # CNI·Ingress·Storage 등 확장 구성
├── operations/     # 설치 후 클러스터 운영·점검·장애 분석
├── theory/         # Addon·Operations 이론
├── devops/         # CI/CD 템플릿
└── examples/       # 실습 파일 생성을 위한 내부 기반 예제
```

## 영역별 문서

`examples/`는 실습 파일을 만들기 위한 원본·참조용 예제다. 학습자는 직접
접근하지 않고 `practice-order/`의 실습 파일만 사용한다.

### 설치

- [Kubernetes 설치 계획](./install/plan.md)
- [Playbook 실행 순서](./install/playbooks/README.md)
- [전체 설치 단계 SVG](./install/installation-flow.svg)

### 실습

Kubernetes 오브젝트와 YAML은 학습 순서에 맞춰
[practice-order](./practice-order/README.md)에 배치한다.

### Addon·Operations

- [Addon·Operations 이론](./theory/addons-operations.md)
- [Addon 자료](./addons/README.md)
- [Operations 자료](./operations/README.md)

### DevOps·DevSecOps

- [Chapter 3 DevOps와 CI/CD](./devops/chapter-03/README.md)
- [19~32 practice-order](./practice-order/chapter-03/README.md)

## 관리 기준

```text
install/        어떻게 구성하는가 — 설치 자동화
practice-order/ 어떤 순서로 학습하는가 — 실제 실습 YAML
addons/         어떻게 확장하는가 — 클러스터 기능 확장
operations/     현재 어떤 상태인가 — 조회·점검·장애 대응
theory/         개념을 어떻게 이해하는가 — Addon·Operations 이론
examples/       실습 파일을 만들기 위한 내부 기반 예제
```

Secret과 kubeconfig는 저장소에 커밋하지 않는다.
