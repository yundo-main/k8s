# Kubernetes 운영

Operations의 범위와 선택적 확장 구성요소의 관계는
[Operations 이론](./operations-theory.md)에서 먼저 확인한다.

설치가 완료된 클러스터를 조회·점검·문제 해결하는 운영 명령을 관리한다.

Kubernetes의 기본 구성과 리소스 관계는 먼저 [구조·매니페스트 리소스 문서](./00-resources/README.md)에서
확인한다.

![Operations 전체 흐름](./operations-overview.svg)

![Operations 하위 디렉터리 관계](./operations-hierarchy.svg)

구성요소 관계는 [Kubernetes 클러스터 구성도](./00-resources/kubernetes-architecture.svg)와
[오버레이 네트워크 흐름도](./04-network/kubernetes-overlay-network.svg),
[Kubernetes 특징](./00-resources/kubernetes-features.svg)에서 확인한다.

Kubernetes 계층 구조와 매니페스트 필드, `kubectl` 리소스 명령어의 기본 흐름은
[구조와 매니페스트 리소스 운영](./00-resources/README.md)에서 먼저 확인한다.

```text
k8s/operations/
├── operations-theory.md # Operations 개념과 하위 영역 이론
├── 00-resources/        # Kubernetes 구조·매니페스트·리소스 명령어
├── 01-cluster/          # 클러스터 전체 상태와 기본 정보
├── 02-nodes/            # 노드 상태·자원·이벤트
├── 03-workloads/        # Pod·Deployment·Job 상태
├── 04-network/          # Service·Ingress·Endpoint 통신
├── 05-storage/          # PV·PVC·StorageClass 상태
├── 06-troubleshooting/  # 장애 분석과 이벤트 확인
└── 07-addons/           # 선택 확장 구성요소 운영
```

`practice-order/`는 선언할 리소스 YAML을, `operations/`는 이미 설치된 클러스터와
리소스의 상태를 점검하는 명령과 참고 자료를 관리한다. `07-addons/`는 기본 운영
영역을 학습한 뒤 필요한 경우 참고하는 선택 확장 영역이다.

## 하위 디렉터리 관계

| 디렉터리 | 운영 대상 | 다른 영역과의 관계 |
| --- | --- | --- |
| [`00-resources/`](./00-resources/README.md) | 구조, 매니페스트, `kubectl` 리소스 명령 | 모든 운영 영역의 공통 진입점 |
| [`01-cluster/`](./01-cluster/README.md) | API Server, 버전, 시스템 Pod | 전체 운영 점검의 시작점 |
| [`02-nodes/`](./02-nodes/README.md) | Node, kubelet, 자원, 이벤트, Taint | 워크로드가 배치되는 실행 기반 |
| [`03-workloads/`](./03-workloads/README.md) | Pod, Deployment, StatefulSet, Job | 애플리케이션 desired state와 실제 상태 |
| [`04-network/`](./04-network/README.md) | Service, Ingress, Endpoint, 정책 | 외부 요청과 Pod 간 통신 경로 |
| [`05-storage/`](./05-storage/README.md) | PV, PVC, StorageClass | 워크로드의 데이터 연결과 보존 |
| [`06-troubleshooting/`](./06-troubleshooting/README.md) | 이벤트, describe, logs | 모든 영역의 장애 분석과 복구 검증 |
| [`07-addons/`](./07-addons/README.md) | CNI, Ingress Controller, CSI, Metrics | 기본 운영 이후 필요한 확장 구성요소 |

`resources/`에서 공통 개념과 명령어를 익힌 뒤 `cluster/`와 `nodes/`에서 기반
상태를 확인한다. 이후 `workloads/`, `network/`, `storage/` 순서로 애플리케이션
구성요소를 점검하고, 문제가 발생하면 `troubleshooting/`에서 원인을 분석한다.
`07-addons/`는 기본 영역을 이해한 뒤 CNI·CSI·Ingress·Metrics 같은 확장 기능이
필요할 때 점검하는 선택 영역이다. 기본 운영 흐름을 대체하거나 우선하지 않는다.
