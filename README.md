# Kubernetes 학습 및 운영 문서

이 디렉터리는 Kubernetes 설치, 학습 실습, 클러스터 확장, 운영 명령을 역할별로
분리해 관리한다.

- [Kubernetes 실습 순서](./practice-order/README.md)
- [Addon·Operations 이론](./operations/addons-operations.md)

## 디렉터리 구조

```text
k8s/
├── install/         # Lesson 0 Ansible 기반 Kubernetes 설치
├── practice-order/ # 학습 순서별 실제 실습 파일
├── operations/     # 설치 후 상태 확인·Addon 운영·Addon 이론
└── examples/       # 실습 파일 생성을 위한 내부 기반 예제
```

## 영역별 문서

`examples/`는 실습 파일을 만들기 위한 원본·참조용 예제다. 학습자는 직접
접근하지 않고 `practice-order/`의 실습 파일만 사용한다.

### Lesson 0. Kubernetes 설치

- [Kubernetes 설치 계획](./install/plan.md)
- [Playbook 실행 순서](./install/playbooks/README.md)
- [Addon 설치 순서](./install/addons/README.md)
- [전체 설치 단계 SVG](./install/installation-flow.svg)

### 실습

Kubernetes 오브젝트와 YAML은 학습 순서에 맞춰
[practice-order](./practice-order/README.md)에 배치한다.

### Addon·Operations

- [Addon·Operations 이론](./operations/addons-operations.md)
- [운영 Addon 자료](./operations/addons/README.md)
- [Operations 자료](./operations/README.md)

### DevOps·DevSecOps

- [19~32 실습 순서](./practice-order/chapter-03/README.md)

## 관리 기준

```text
practice-order/ 어떤 순서로 학습하는가 — Lesson 0 설치부터 실제 실습 YAML까지
operations/     현재 상태·Addon 운영·Addon Operations 이론
examples/       실습 파일을 만들기 위한 내부 기반 예제
```

Secret과 kubeconfig는 저장소에 커밋하지 않는다.
